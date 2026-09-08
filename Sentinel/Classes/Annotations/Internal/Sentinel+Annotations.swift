//
//  Sentinel+Annotations.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Foundation

extension Sentinel {

    /// Whether the Sentinel panel is currently on screen.
    ///
    /// Asked of the configured `SourceScreenProvider` rather than checked directly, so a host
    /// app that presents Sentinel its own way is still answered correctly.
    var isPanelShown: Bool {
        configuration?.sourceScreenProvider.isShown() ?? false
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
}

#endif
