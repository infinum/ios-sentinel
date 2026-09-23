//
//  WebDataCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation
import WebKit

#if os(iOS)

/// Removes cached responses, cookies and web view storage.
enum WebDataCleaner {

    static func clearURLCache() {
        URLCache.shared.removeAllCachedResponses()
    }

    static func clearCookies() -> [ClearAppDataFailure] {
        let storage = HTTPCookieStorage.shared
        storage.removeCookies(since: .distantPast)
        storage.cookies?.forEach(storage.deleteCookie)

        let remaining = storage.cookies?.count ?? 0
        guard remaining > 0 else { return [] }
        return [ClearAppDataFailure(step: .cookies, reason: "\(remaining) cookies could not be removed")]
    }

    /// Clears every web site data type, blocking until WebKit reports back.
    ///
    /// - Warning: Must not be called from the main queue — the work is dispatched there.
    static func clearWebsiteData(timeout: DispatchTimeInterval) -> [ClearAppDataFailure] {
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {
            let store = WKWebsiteDataStore.default()
            store.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                modifiedSince: .distantPast,
                completionHandler: { group.leave() }
            )
        }

        // WebKit occasionally never calls back when its networking process is wedged, and the tool
        // must not hang on it.
        guard group.wait(timeout: .now() + timeout) == .success else {
            return [ClearAppDataFailure(step: .websiteData, reason: "timed out waiting for WebKit")]
        }
        return []
    }
}

#endif
