//
//  ScreenIdentity.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Names the screen an annotated element belongs to.
///
/// Two names are recorded, coarse and fine, the way the Android port records both the Activity
/// and the Fragment: the topmost *presented* view controller is the screen the user was looking
/// at, and the deepest view controller covering the target is the container that actually owns
/// it — a cell's controller, a page in a page view controller, a child controller in a custom
/// container.
enum ScreenIdentity {

    // MARK: - Private properties

    private enum Constants {
        static let maxContainerDepth = 32
    }

    // MARK: - Internal methods

    /// The view controller the user is actually looking at.
    ///
    /// Walks the presentation chain, then unwraps the standard containers: a bare
    /// `rootViewController` is very often a `UINavigationController`, whose own name says
    /// nothing about which screen is on top of its stack.
    static func topmostViewController(in window: UIWindow) -> UIViewController? {
        guard var controller = window.rootViewController else { return nil }

        // Bounded rather than `while true`: the loop follows references the host app owns, and a
        // container that reports itself as its own visible child would otherwise hang the app.
        for _ in 0..<Constants.maxContainerDepth {
            if let presented = controller.presentedViewController {
                controller = presented
            } else if let navigation = controller as? UINavigationController,
                      let visible = navigation.visibleViewController, visible !== controller {
                controller = visible
            } else if let tabs = controller as? UITabBarController,
                      let selected = tabs.selectedViewController, selected !== controller {
                controller = selected
            } else {
                break
            }
        }
        return controller
    }

    /// Name of the screen the user is looking at.
    ///
    /// A `UIHostingController` reports the app's own root view type instead of its own class,
    /// which is otherwise the same generic name on every SwiftUI screen in the app.
    static func screenName(in window: UIWindow) -> String? {
        guard let controller = topmostViewController(in: window) else { return nil }
        let className = NSStringFromClass(type(of: controller))
        return SwiftUIIdentity.appTypeName(in: className) ?? SwiftUIIdentity.simpleTypeName(of: controller)
    }

    /// Class name of the deepest view controller whose view covers `screenPoint`.
    ///
    /// Returns `nil` when that is the screen itself, so the coarse and the fine name never
    /// report the same thing twice.
    static func viewControllerName(in window: UIWindow, containing screenPoint: CGPoint) -> String? {
        guard let root = window.rootViewController else { return nil }
        let topmost = topmostViewController(in: window)

        var deepest: (controller: UIViewController, depth: Int)?

        func visit(_ controller: UIViewController, depth: Int) {
            if controller.viewIfLoaded?.sentinelScreenFrame.contains(screenPoint) == true,
               depth > (deepest?.depth ?? -1) {
                deepest = (controller, depth)
            }
            controller.children.forEach { visit($0, depth: depth + 1) }
            if let presented = controller.presentedViewController {
                visit(presented, depth: depth + 1)
            }
        }

        visit(root, depth: 0)

        guard let found = deepest, found.controller !== topmost else { return nil }
        return SwiftUIIdentity.simpleTypeName(of: found.controller)
    }
}

#endif
