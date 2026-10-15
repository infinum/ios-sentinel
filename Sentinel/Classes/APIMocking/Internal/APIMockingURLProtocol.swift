//
//  APIMockingURLProtocol.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

/// Answers requests that match a switched-on mock, in place of the network.
final class APIMockingURLProtocol: URLProtocol {

    /// Pulse marks a logged request as mocked when its current request carries this header.
    static let pulseMockedHeaderName = "X-PulseRequestMocked"
    /// Added to every mocked response, naming the mock that answered.
    static let mockHeaderName = "X-Sentinel-Mock"

    // Only read and written on the thread that loads the request.
    private var isStopped = false

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        APIMockMatcher.shared.mock(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var request = request
        // `setValue`, not `addValue`: a request can be canonicalized more than once.
        request.setValue("true", forHTTPHeaderField: pulseMockedHeaderName)
        return request
    }

    override func startLoading() {
        // Looked up again, as the mock may have been switched off since `canInit`.
        let mock = APIMockMatcher.shared.mock(for: request)
        // The client is called back on the thread that started loading, as URLProtocol requires,
        // which also keeps `isStopped` on a single thread.
        let runLoop = CFRunLoopGetCurrent()
        DispatchQueue.global().asyncAfter(deadline: .now() + (mock?.delay ?? 0)) { [weak self] in
            CFRunLoopPerformBlock(runLoop, CFRunLoopMode.commonModes.rawValue) {
                guard let self, !self.isStopped else { return }
                self.respond(with: mock)
            }
            CFRunLoopWakeUp(runLoop)
        }
    }

    override func stopLoading() {
        isStopped = true
    }
}

// MARK: - Responding

private extension APIMockingURLProtocol {

    func respond(with mock: APIMock?) {
        guard let mock else {
            fail(
                with: .resourceUnavailable,
                description: "The Sentinel API mock for this request was switched off before it answered."
            )
            return
        }

        switch mock.response {
        case .networkError(let error):
            fail(with: error.code, description: error.systemDescription)
        case .http(let statusCode, let headers, let body):
            respond(
                to: mock,
                statusCode: statusCode,
                headers: headers,
                body: body
            )
        }
    }

    func respond(
        to mock: APIMock,
        statusCode: Int,
        headers: [String: String],
        body: APIMock.Body
    ) {
        let data: Data
        do {
            data = try body.loadData()
        } catch {
            fail(
                with: .resourceUnavailable,
                description: "The Sentinel API mock “\(mock.name)” couldn't read its body: \(error.localizedDescription)"
            )
            return
        }

        guard let url = request.url,
              let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: responseHeaders(for: mock, overrides: headers)
              )
        else {
            fail(with: .badServerResponse)
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    func responseHeaders(for mock: APIMock, overrides: [String: String]) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            Self.mockHeaderName: mock.id
        ]
        // Header names are case-insensitive, so an override replaces a default spelled differently.
        for (name, value) in overrides {
            headers.keys
                .filter { $0.caseInsensitiveCompare(name) == .orderedSame }
                .forEach { headers.removeValue(forKey: $0) }
            headers[name] = value
        }
        return headers
    }

    func fail(with code: URLError.Code, description: String? = nil) {
        var userInfo: [String: Any] = [:]
        if let url = request.url {
            userInfo[NSURLErrorFailingURLErrorKey] = url
            userInfo[NSURLErrorFailingURLStringErrorKey] = url.absoluteString
        }
        if let description {
            userInfo[NSLocalizedDescriptionKey] = description
        }
        client?.urlProtocol(self, didFailWithError: URLError(code, userInfo: userInfo))
    }
}
