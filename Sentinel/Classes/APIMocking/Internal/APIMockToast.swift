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
}
