//
//  APIMockToast.swift
//  Sentinel
//
//  Created by Nikola Simunko on 05.11.2026..
//

import Foundation

/// What a toast over the app says about API mocking.
struct APIMockToastMessage: Equatable {

    let title: String
    let subtitle: String
}

extension APIMockToastMessage {

    /// Shown at launch, as mocks stay on across launches and are easy to forget.
    static func launch(activeMocks: [APIMock]) -> APIMockToastMessage {
        let subtitle: String
        if activeMocks.count == 1, let mock = activeMocks.first {
            subtitle = "“\(mock.name)” answers requests"
        } else {
            subtitle = "\(activeMocks.count) mocks answer requests"
        }
        return APIMockToastMessage(
            title: "API mocking is on",
            subtitle: subtitle
        )
    }

    static func request(_ request: URLRequest, mockedBy mock: APIMock) -> APIMockToastMessage {
        // A mock without a method answers any, so the request says which one it was.
        let method = mock.method?.rawValue ?? request.httpMethod ?? "GET"
        let path = request.url?.path ?? ""
        return APIMockToastMessage(
            title: "Mocked by “\(mock.name)”",
            subtitle: "\(method) \(path.isEmpty ? "/" : path) · \(mock.responseSummary)"
        )
    }
}

/// Mocked requests that arrive while a toast is up, so a burst of them updates one toast.
struct APIMockRequestBurst {

    private var count = 0
    private var mockIDs = Set<String>()

    mutating func add(_ request: URLRequest, mockedBy mock: APIMock) -> APIMockToastMessage {
        count += 1
        mockIDs.insert(mock.id)
        if count == 1 {
            return APIMockToastMessage.request(request, mockedBy: mock)
        }
        if mockIDs.count == 1 {
            return APIMockToastMessage(
                title: "Mocked by “\(mock.name)”",
                subtitle: "Answered \(count) requests"
            )
        }
        return APIMockToastMessage(
            title: "\(count) requests mocked",
            subtitle: "By \(mockIDs.count) mocks"
        )
    }
}
