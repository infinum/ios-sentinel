//
//  SwiftUIIdentity.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Recovers what little identity SwiftUI exposes to a running process.
///
/// SwiftUI draws its own content: `Text`, `Button` and the rest produce **no backing `UIView`
/// at all** (verified on device), and the accessibility element tree they would otherwise
/// expose is only built while an assistive technology is running. So a tap inside a SwiftUI
/// hierarchy resolves to the hosting view, not to the view the user pointed at — unless SwiftUI
/// happens to bridge that control to a real UIKit one, as it does for `Toggle` and `UISwitch`.
///
/// What *is* always recoverable is the generic parameter of the enclosing `_UIHostingView` or
/// `UIHostingController`, which names the app's own root view type:
/// `_UIHostingView<ModifiedContent<CheckoutScreen, _PaddingLayout>>` yields `CheckoutScreen`,
/// which is the file an agent should open. This is the same trade-off the Android port
/// documents for Compose.
///
/// Names are read with `String(reflecting:)` rather than `NSStringFromClass`: a generic Swift
/// class reports a *mangled* ObjC name (`_TtGC7SwiftUI14_UIHostingView...`) that carries no
/// parseable `<...>` at all.
enum SwiftUIIdentity {

    // MARK: - Private properties

    private enum Constants {
        static let hostingViewMarker = "_UIHostingView"
        static let hostingControllerMarker = "HostingController"

        /// The view SwiftUI wraps a `UIViewRepresentable` in. Its generic parameter names the
        /// app's own representable type, which is a far better locator than the root view.
        static let platformHostMarker = "UIKitPlatformViewHost"

        static let frameworkPrefixes = ["SwiftUI.", "UIKit.", "Sentinel.", "_"]
    }

    // MARK: - Internal methods

    /// Whether `view` is the UIKit view a SwiftUI hierarchy is rendered into.
    static func isHostingView(_ view: UIView) -> Bool {
        qualifiedName(of: view).contains(Constants.hostingViewMarker)
    }

    /// The fully qualified, demangled type name of `object`, generic parameters included.
    static func qualifiedName(of object: AnyObject) -> String {
        String(reflecting: type(of: object))
    }

    /// Whether `view` is a SwiftUI host whose generic parameter may name an app type: the view
    /// a whole hierarchy is rendered into, or the wrapper around one `UIViewRepresentable`.
    static func isSwiftUIHost(_ view: UIView) -> Bool {
        let name = qualifiedName(of: view)
        return name.contains(Constants.hostingViewMarker) || name.contains(Constants.platformHostMarker)
    }

    /// The app's own SwiftUI view type hosting `view`, or `nil` when there is none to recover.
    ///
    /// Walks outward and takes the first host that yields an app type, so the innermost and
    /// therefore most specific one wins: a `UIViewRepresentable`'s own type is reported in
    /// preference to the root view type several levels above it.
    ///
    /// Falls back to the nearest hosting controller in the responder chain — a
    /// `UIHostingController` used as a child view controller keeps its root type in its own
    /// class name rather than in the view's.
    ///
    /// Returns `nil` for a SwiftUI-lifecycle app whose content is not reached through either: a
    /// `WindowGroup` root is erased to `_UIHostingView<ModifiedContent<AnyView, RootModifier>>`,
    /// which names nothing of the app's own.
    static func rootTypeName(for view: UIView) -> String? {
        var current: UIView? = view
        while let candidate = current {
            if isSwiftUIHost(candidate), let name = appTypeName(in: qualifiedName(of: candidate)) {
                return name
            }
            current = candidate.superview
        }

        var responder: UIResponder? = view
        while let candidate = responder {
            if let controller = candidate as? UIViewController {
                let name = qualifiedName(of: controller)
                if name.contains(Constants.hostingControllerMarker), let root = appTypeName(in: name) {
                    return root
                }
            }
            responder = candidate.next
        }
        return nil
    }

    /// The first type in `name` that belongs to the app rather than to SwiftUI or UIKit.
    ///
    /// Recurses through generic parameters, so a root buried under `ModifiedContent` wrappers is
    /// still found. Returns `nil` for a hierarchy that exposes nothing but framework types —
    /// `_UIHostingView<AnyView>`, typically — because naming `AnyView` would help nobody.
    ///
    /// Expects a qualified name from ``qualifiedName(of:)``. A file-private view type is
    /// reported as `MyModule.(unknown context at $...).MyView`; taking the last dotted component
    /// still yields `MyView`.
    static func appTypeName(in name: String) -> String? {
        let base = String(name.prefix(while: { $0 != "<" }))
        if !base.isEmpty, !Constants.frameworkPrefixes.contains(where: { base.hasPrefix($0) }) {
            return simpleName(of: base)
        }
        for argument in genericArguments(in: name) {
            if let found = appTypeName(in: argument) {
                return found
            }
        }
        return nil
    }

    /// The class name of `object` without its module prefix or generic parameters.
    ///
    /// `String(describing:)` rather than `NSStringFromClass`, which reports a mangled name for
    /// a generic Swift class and would leave `_TtGC7SwiftUI14_UIHostingView...` in the payload.
    static func simpleTypeName(of object: AnyObject) -> String {
        let described = String(describing: type(of: object))
        return simpleName(of: String(described.prefix(while: { $0 != "<" })))
    }

    // MARK: - Private methods

    private static func simpleName(of name: String) -> String {
        name.split(separator: ".").last.map(String.init) ?? name
    }

    /// The top-level generic arguments of `name`, e.g. `["A", "B<C, D>"]` for `T<A, B<C, D>>`.
    private static func genericArguments(in name: String) -> [String] {
        guard let start = name.firstIndex(of: "<") else { return [] }

        var arguments: [String] = []
        var current = ""
        var depth = 0

        for character in name[name.index(after: start)...] {
            switch character {
            case "<":
                depth += 1
                current.append(character)
            case ">":
                if depth == 0 {
                    arguments.append(current.trimmingCharacters(in: .whitespaces))
                    return arguments.filter { !$0.isEmpty }
                }
                depth -= 1
                current.append(character)
            case "," where depth == 0:
                arguments.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            default:
                current.append(character)
            }
        }

        arguments.append(current.trimmingCharacters(in: .whitespaces))
        return arguments.filter { !$0.isEmpty }
    }
}

#endif
