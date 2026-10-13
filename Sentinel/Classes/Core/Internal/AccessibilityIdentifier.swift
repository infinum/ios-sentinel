//
//  AccessibilityIdentifier.swift
//  Sentinel
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation

/// Accessibility identifiers for the Sentinel UI, used by the example app's UI tests.
///
/// Tab bar buttons and the search field aren't listed: SwiftUI doesn't forward identifiers set on
/// `tabItem` or `searchable`, so tests find those by their visible labels.
enum AccessibilityIdentifier {

    static func row(_ title: String) -> String { "sentinel.row.\(title)" }
    static func toggle(_ title: String) -> String { "sentinel.toggle.\(title)" }
    static func apiMockingGroup(_ name: String) -> String { "sentinel.apiMocking.group.\(name)" }

    static let clearAllDataButton = "sentinel.clearAppData.clearAll"
    static let textEditingField = "sentinel.textEditing.field"
    static let textEditingSaveButton = "sentinel.textEditing.save"
    static let userDefaultsEditor = "sentinel.userDefaults.editor"
    static let userDefaultsSaveButton = "sentinel.userDefaults.save"
    static let userDefaultsDeleteButton = "sentinel.userDefaults.delete"
    static let crashesDeleteAllButton = "sentinel.crashes.deleteAll"
    static let apiMockingMasterSwitch = "sentinel.apiMocking.masterSwitch"
    static let apiMockingNewButton = "sentinel.apiMocking.new"
    static let apiMockingNameField = "sentinel.apiMocking.name"
    static let apiMockingGroupField = "sentinel.apiMocking.groupField"
    static let apiMockingPatternField = "sentinel.apiMocking.pattern"
    static let apiMockingBodyRow = "sentinel.apiMocking.bodyRow"
    static let apiMockingBodyEditor = "sentinel.apiMocking.body"
    static let apiMockingSaveButton = "sentinel.apiMocking.save"
    static let macConnectionSwitch = "sentinel.macConnection.switch"
    static let macConnectionConfirmButton = "sentinel.macConnection.confirm"
}
