//
//  ClearAppDataReport.swift
//  Sentinel
//
//  Created by Nikola Simunko on 22.09.2025..
//

import Foundation

// MARK: - Step

/// A single unit of work performed when clearing the app data.
enum ClearAppDataStep: CaseIterable {
    case urlCache
    case cookies
    case websiteData
    case keychain
    case userDefaults
    case temporaryDirectory
    case cachesDirectory
    case applicationSupportDirectory
    case documentsDirectory

    var title: String {
        switch self {
        case .urlCache: return "URL cache"
        case .cookies: return "Cookies"
        case .websiteData: return "Web site data"
        case .keychain: return "Keychain"
        case .userDefaults: return "User defaults"
        case .temporaryDirectory: return "Temporary directory"
        case .cachesDirectory: return "Caches directory"
        case .applicationSupportDirectory: return "Application Support directory"
        case .documentsDirectory: return "Documents directory"
        }
    }
}

// MARK: - Failure

/// Describes a single item which could not be cleared.
struct ClearAppDataFailure {

    /// Distinguishes a genuine error from an item the system refuses to hand over.
    ///
    /// Directories such as `Caches/Snapshots` are managed by the OS and cannot be removed by the
    /// app. Reporting those as failures would make a healthy run look broken, so they are listed
    /// separately and do not affect ``ClearAppDataReport/isFullySuccessful``.
    enum Kind {
        case failed
        case skipped
    }

    let step: ClearAppDataStep
    let item: String?
    let reason: String
    let kind: Kind

    init(step: ClearAppDataStep, item: String? = nil, reason: String, kind: Kind = .failed) {
        self.step = step
        self.item = item
        self.reason = reason
        self.kind = kind
    }
}

// MARK: - Report

/// The outcome of a clearing run, rendered into the alert shown once it finishes.
struct ClearAppDataReport {

    /// Number of failure lines listed before the rest are collapsed into a counter.
    private static let maxListedFailures = 5

    let failures: [ClearAppDataFailure]

    var isFullySuccessful: Bool {
        !failures.contains { $0.kind == .failed }
    }

    var title: String {
        isFullySuccessful ? "Data cleared" : "Cleared with errors"
    }

    @StringBuilder
    var message: String {
        let listed = failures.prefix(Self.maxListedFailures)
        for failure in listed {
            line(for: failure)
            String.newLine
        }

        let remaining = failures.count - listed.count
        if remaining > 0 {
            "…and \(remaining) more"
            String.newLine
        }

        if !failures.isEmpty {
            String.newLine
        }

        "Force-quit the app and launch it again. Data already loaded in memory is still active until you do."
    }
}

// MARK: - Helpers

private extension ClearAppDataReport {

    func line(for failure: ClearAppDataFailure) -> String {
        let subject = failure.item.map { "\(failure.step.title) — \($0)" } ?? failure.step.title
        switch failure.kind {
        case .failed:
            return "• \(subject): \(failure.reason)"
        case .skipped:
            return "• \(subject): skipped (system-managed)"
        }
    }
}
