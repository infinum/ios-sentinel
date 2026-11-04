//
//  WebDataCleaner.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

#if os(iOS)

import Foundation
import WebKit

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

    /// Clears every web site data type, calling back on the main queue once WebKit has finished or
    /// `timeout` has passed, whichever comes first.
    ///
    /// - Warning: Must be called from the main queue.
    static func clearWebsiteData(
        timeout: DispatchTimeInterval,
        completion: @escaping ([ClearAppDataFailure]) -> Void
    ) {
        dispatchPrecondition(condition: .onQueue(.main))

        // Both callbacks run on main, so the flag needs no lock.
        var didFinish = false
        let finish = { (failures: [ClearAppDataFailure]) in
            guard !didFinish else { return }
            didFinish = true
            completion(failures)
        }

        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast,
            completionHandler: { finish([]) }
        )

        // WebKit occasionally never calls back when its networking process is wedged, and the tool
        // must not hang on it.
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            finish([ClearAppDataFailure(step: .websiteData, reason: "timed out waiting for WebKit")])
        }
    }
}

#endif
