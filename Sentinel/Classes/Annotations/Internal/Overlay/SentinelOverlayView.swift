//
//  SentinelOverlayView.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Marks a view as Sentinel's own overlay chrome, so target resolution never selects it.
///
/// The capture overlay lives in its own `UIWindow` and is therefore already outside the app's
/// view hierarchy. This marker is the second line of defence: it keeps a Sentinel view out of
/// the tree even if it is ever hosted inside the app's window, where — being full screen and
/// childless — it would otherwise be the deepest hit for every single tap.
protocol SentinelOverlayView: UIView {}

#endif
