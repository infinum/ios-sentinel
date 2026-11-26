//
//  AnnotationToolkit.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import Foundation

/// The UI toolkit an annotated element belongs to.
///
/// The raw values are deliberately platform specific — `uikit` and `swiftui` rather than the
/// `view` and `compose` the Android library emits — so a single Claude Code routine can tell
/// an iOS batch from an Android one without an extra field.
public enum AnnotationToolkit: String, Encodable, Sendable {

    /// The element is a plain `UIView` the app or UIKit created.
    case uiKit = "uikit"

    /// The element lives inside a SwiftUI hosting view.
    case swiftUI = "swiftui"
}

#endif
