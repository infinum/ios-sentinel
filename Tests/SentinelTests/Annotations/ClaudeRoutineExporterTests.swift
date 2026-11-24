//
//  ClaudeRoutineExporterTests.swift
//  SentinelTests
//

#if canImport(UIKit)

import XCTest
@testable import Sentinel

final class ClaudeRoutineExporterTests: XCTestCase {

    private let fireUrl = "https://api.anthropic.com/v1/claude_code/routines/abc/fire"

    func testExportPostsTheBatchWithTheExpectedHeadersAndBody() async throws {
        let poster = FakeHTTPPoster(response: HTTPResponse(statusCode: 200, body: "{}"))
        let exporter = ClaudeRoutineExporter(token: { "token-123" }, fireUrl: fireUrl, poster: poster)

        let message = try await exporter.export([makeAnnotation(id: "one")])

        XCTAssertEqual(message, "Sent 1 annotations")
        let captured = await poster.lastRequest
        let request = try XCTUnwrap(captured)
        XCTAssertEqual(request.url, fireUrl)
        XCTAssertEqual(request.headers["Authorization"], "Bearer token-123")
        XCTAssertEqual(request.headers["anthropic-version"], "2023-06-01")
        XCTAssertEqual(request.headers["anthropic-beta"], "experimental-cc-routine-2026-04-01")
        XCTAssertEqual(request.headers["Content-Type"], "application/json")

        // The routine reads the batch out of a single `text` turn.
        let body = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: Data(request.body.utf8)) as? [String: Any]
        )
        let payload = try XCTUnwrap(body["text"] as? String)
        let batch = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: Data(payload.utf8)) as? [[String: Any]]
        )
        XCTAssertEqual(batch.first?["id"] as? String, "one")
    }

    /// Refusing beats firing an unauthenticated request, which would come back as an opaque 401.
    func testExportRefusesWhenNoTokenIsConfigured() async {
        let poster = FakeHTTPPoster(response: HTTPResponse(statusCode: 200, body: "{}"))
        let exporter = ClaudeRoutineExporter(token: { nil }, fireUrl: fireUrl, poster: poster)

        await assertThrows(AnnotationExportError.missingToken) {
            _ = try await exporter.export([self.makeAnnotation(id: "one")])
        }
        let request = await poster.lastRequest
        XCTAssertNil(request, "nothing must be sent without a token")
    }

    func testExportRefusesABlankToken() async {
        let poster = FakeHTTPPoster(response: HTTPResponse(statusCode: 200, body: "{}"))
        let exporter = ClaudeRoutineExporter(token: { "   " }, fireUrl: fireUrl, poster: poster)

        await assertThrows(AnnotationExportError.missingToken) {
            _ = try await exporter.export([self.makeAnnotation(id: "one")])
        }
    }

    func testExportReportsTheStatusAndBodyOfAFailedRequest() async {
        let poster = FakeHTTPPoster(response: HTTPResponse(statusCode: 403, body: "forbidden"))
        let exporter = ClaudeRoutineExporter(token: { "token" }, fireUrl: fireUrl, poster: poster)

        do {
            _ = try await exporter.export([makeAnnotation(id: "one")])
            XCTFail("expected the export to throw")
        } catch let error as AnnotationExportError {
            guard case .requestFailed(let statusCode, let body) = error else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertEqual(statusCode, 403)
            XCTAssertEqual(body, "forbidden")
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testClipboardExporterCopiesTheBatchAndReportsTheCount() async throws {
        let exporter = ClipboardAnnotationExporter()

        let message = try await exporter.export([makeAnnotation(id: "one"), makeAnnotation(id: "two")])

        XCTAssertEqual(message, "Copied 2 annotations")
    }

    // MARK: - Helpers

    private func makeAnnotation(id: String) -> SentinelAnnotation {
        SentinelAnnotation(
            id: id,
            note: "too small",
            toolkit: .uiKit,
            targetType: "UIButton",
            targetPath: "UIStackView>UIButton",
            accessibilityIdentifier: "submitButton"
        )
    }

    private func assertThrows(
        _ expected: AnnotationExportError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () async throws -> Void
    ) async {
        do {
            try await body()
            XCTFail("expected \(expected)", file: file, line: line)
        } catch let error as AnnotationExportError {
            XCTAssertEqual(error.errorDescription, expected.errorDescription, file: file, line: line)
        } catch {
            XCTFail("unexpected error: \(error)", file: file, line: line)
        }
    }
}

// MARK: - Fake

private actor FakeHTTPPoster: HTTPPoster {

    struct Request {
        let url: String
        let headers: [String: String]
        let body: String
    }

    private(set) var lastRequest: Request?

    private let response: HTTPResponse

    init(response: HTTPResponse) {
        self.response = response
    }

    func post(url: String, headers: [String: String], body: String) async throws -> HTTPResponse {
        lastRequest = Request(url: url, headers: headers, body: body)
        return response
    }
}

#endif
