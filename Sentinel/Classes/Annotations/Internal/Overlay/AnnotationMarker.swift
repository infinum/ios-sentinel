//
//  AnnotationMarker.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import CoreGraphics
import Foundation

/// A saved note resolved to its current on-screen position, ready to draw.
///
/// `number` is the 1-based position in the store, so a note keeps its number even while other
/// notes are hidden on another screen.
struct AnnotationMarker: Equatable {

    let number: Int
    let screenFrame: CGRect
    let annotation: SentinelAnnotation
}

#endif
