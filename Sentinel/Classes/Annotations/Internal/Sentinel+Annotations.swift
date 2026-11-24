//
//  Sentinel+Annotations.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import SwiftUI
import UIKit

extension Sentinel {

    /// Whether the Sentinel panel is currently on screen.
    ///
    /// Asks the configured `SourceScreenProvider` first, so a host app that presents Sentinel
    /// its own way is still answered correctly. The default provider only looks at the topmost
    /// view controller, though, so it says no while anything, such as an alert, is presented
    /// over the panel. The presentation chains are therefore checked as well.
    var isPanelShown: Bool {
        guard let configuration = configuration else { return false }
        return configuration.sourceScreenProvider.isShown() || Self.isPanelInPresentationChain()
    }

    /// Whether `chain` holds the Sentinel panel at any position, not only at the top.
    static func containsPanel(_ chain: [UIViewController]) -> Bool {
        chain.contains { $0 is UIHostingController<SentinelTabBarView> }
    }

    /// Re-presents the Sentinel panel. Used by the capture overlay's stop control, whose long
    /// press reopens Sentinel with capture left armed.
    func presentPanel() {
        guard let configuration = configuration, !configuration.sourceScreenProvider.isShown() else { return }
        configuration.sourceScreenProvider.showTools(for: Sentinel.createSentinelView(with: configuration))
    }

    /// Dismisses the Sentinel panel, so arming capture lands the user back on the live app.
    func dismissPanel() {
        configuration?.sourceScreenProvider.dismiss()
    }

    // MARK: - Private methods

    private static func isPanelInPresentationChain() -> Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .contains { containsPanel(presentationChain(from: $0.rootViewController)) }
    }

    private static func presentationChain(from root: UIViewController?) -> [UIViewController] {
        var chain: [UIViewController] = []
        var current = root
        while let controller = current {
            chain.append(controller)
            current = controller.presentedViewController
        }
        return chain
    }
}

#endif
