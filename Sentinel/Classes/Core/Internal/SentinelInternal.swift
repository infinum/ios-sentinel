//
//  SentinelInternal.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import Foundation

// MARK: - Helpers

extension Sentinel {
    
    static func createTabItems(
        with tools: [Tool],
        preferences: [PreferencesTool.Section],
        showsTouchesToggle: Bool = true
    ) -> [SentinelTabItem] {
        let builtIn = showsTouchesToggle ? builtInPreferences : []
        let report = SentinelReport()
        return [
            SentinelTabItem(tab: .device, report: report),
            SentinelTabItem(tab: .application, report: report),
            SentinelTabItem(tab: .tools(items: tools)),
            SentinelTabItem(tab: .preferences(items: builtIn + preferences)),
            SentinelTabItem(tab: .performance)
        ]
    }

    /// Brings back the built-in preferences' state saved in a previous launch, unless the configuration leaves them out.
    ///
    /// Called eagerly from both public entry points: nothing else reaches `TouchVisualizer.shared` before Sentinel is
    /// first opened, so restoring lazily would hide the touches after a relaunch until then.
    static func restoreBuiltInPreferences(for configuration: Configuration) {
        #if os(iOS)
        guard configuration.showsTouchesToggle else { return }
        TouchVisualizer.shared.restore()
        #endif
    }

    func preselectedTabIndex(for tab: SentinelTab, tabItems: [SentinelTabItem]) -> Int {
        tabItems
            .enumerated()
            .first(where: {
                guard case .tools = $0.element.tab else { return false }
                return true
            })
            .map(\.offset) ?? 0
    }
}

// MARK: - Private helpers

private extension Sentinel {

    static var builtInPreferences: [PreferencesTool.Section] {
        #if os(iOS)
        [
            // A fixed id, so an app section titled "Sentinel" doesn't share this section's identity.
            PreferencesTool.Section(
                id: "com.infinum.sentinel.builtInPreferences",
                title: "Sentinel",
                items: [
                    PreferenceToggleItem(
                        title: "Show touches",
                        description: "Shows a circle under each finger, so screen recordings show where you tapped. Stays on after relaunch.",
                        setter: { TouchVisualizer.shared.isEnabled = $0 },
                        getter: { TouchVisualizer.shared.isEnabled }
                    )
                ]
            )
        ]
        #else
        []
        #endif
    }
}
