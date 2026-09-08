//
//  UIViewTargetNode.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Adapts a `UIView` subtree to ``TargetNode``.
///
/// Children are built lazily, so a hit test only ever materialises the branch it descends into.
/// Hidden, transparent and zero-size views are dropped, so what the tree contains is what the
/// user can actually see, and a `UIControl` is walked as a leaf — see ``buildChildren()``.
///
/// `parent` is weak — children hold their parent, so a strong link would retain the whole tree
/// in a cycle. `ResolvedTarget` keeps the root alive for as long as a selection is held.
final class UIViewTargetNode: TargetNode {

    // MARK: - Internal properties

    let view: UIView

    let type: String

    let accessibilityIdentifier: String?

    let accessibilityLabel: String?

    let text: String?

    let screenFrame: CGRect

    let isAnnotatable: Bool

    let isBroadenable: Bool

    let toolkit: AnnotationToolkit

    var parent: TargetNode? { parentNode }

    /// Resolved on demand: walking up to the hosting view for every node in a full tree pass
    /// would make counting ordinals quadratic, and only the selected node ever needs this.
    lazy var swiftUIType: String? = toolkit == .swiftUI ? SwiftUIIdentity.rootTypeName(for: view) : nil

    lazy var children: [TargetNode] = buildChildren()

    // MARK: - Private properties

    private enum Constants {
        /// Views the system owns, which no annotation should ever point at.
        static let chromeTypes: Set<String> = [
            "UIWindow",
            "UITextEffectsWindow",
            "UIRemoteKeyboardWindow",
            "UITransitionView",
            "UIDropShadowView",
            "UILayoutContainerView",
            "UINavigationTransitionView",
            "UIViewControllerWrapperView",
            "UIInputSetContainerView",
            "UIInputSetHostView",
            "UITableViewWrapperView",
            "_UIParallaxDimmingView",
            "_UIVisualEffectBackdropView",
            "_UITableViewCellSeparatorView",
            "_UIPageViewControllerContentView"
        ]

        /// Live text is captured to disambiguate siblings, not to ship the user's content.
        static let maxTextLength = 200

        static let minimumVisibleAlpha: CGFloat = 0.01
    }

    private weak var parentNode: TargetNode?

    private let isInsideHostingView: Bool

    // MARK: - Lifecycle

    init(view: UIView, parent: TargetNode?, isInsideHostingView: Bool = false) {
        self.view = view
        self.parentNode = parent
        self.isInsideHostingView = isInsideHostingView

        type = SwiftUIIdentity.simpleTypeName(of: view)
        accessibilityIdentifier = Self.nonEmpty(view.accessibilityIdentifier)
        accessibilityLabel = Self.nonEmpty(view.accessibilityLabel)
        text = Self.text(of: view)
        screenFrame = view.sentinelScreenFrame
        toolkit = isInsideHostingView || SwiftUIIdentity.isHostingView(view) ? .swiftUI : .uiKit

        let isChrome = Self.isFrameworkChrome(view)
        let annotatable = !isChrome && Self.carriesContent(
            view,
            accessibilityIdentifier: accessibilityIdentifier,
            accessibilityLabel: accessibilityLabel
        )
        isAnnotatable = annotatable
        // Wider than `isAnnotatable`: a layout container counts as a whole section, which is what
        // makes repeated taps walk up the tree. Real hierarchies nest content in anonymous
        // `UIStackView` / `UIView` wrappers carrying nothing to identify them, so without this a
        // leaf would have no ancestor to broaden to and tapping it again would do nothing.
        isBroadenable = annotatable || (!isChrome && !view.subviews.isEmpty)
    }

    // MARK: - Private methods

    /// A `UIControl` is walked as a leaf, so a tap anywhere on it selects the control itself.
    ///
    /// UIKit builds controls out of deep private hierarchies — a `UISwitch` is eight levels of
    /// `UISwitchModernVisualElement`, `_UILiquidLensView` and anonymous `UIView`s — none of which
    /// appears anywhere in an app's source. Descending would make the deepest hit an unusable
    /// private view and force the user to broaden four or five times to reach the control they
    /// obviously meant. A `UIButton`'s own `titleLabel` is the same case.
    ///
    /// The cost is that a custom `UIControl` subclass's app-authored subviews cannot be selected
    /// individually; the control is annotated instead, which is the better default by far.
    private func buildChildren() -> [TargetNode] {
        guard !(view is UIControl) else { return [] }

        let insideHosting = isInsideHostingView || SwiftUIIdentity.isHostingView(view)
        return view.subviews
            .filter { subview in
                !subview.isHidden
                    && subview.alpha >= Constants.minimumVisibleAlpha
                    && !subview.bounds.isEmpty
                    && !(subview is SentinelOverlayView)
            }
            .map { UIViewTargetNode(view: $0, parent: self, isInsideHostingView: insideHosting) }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value, !value.isEmpty else { return nil }
        return value
    }

    /// The element's live visible text — what the user is looking at right now, not a static
    /// label from a storyboard.
    ///
    /// A secure text field is the one exception: its contents are never read, only its
    /// placeholder, which is developer-authored and therefore safe. Without that,
    /// ``ClaudeRoutineExporter`` would POST whatever the user typed into the host app's login
    /// form to an external endpoint.
    private static func text(of view: UIView) -> String? {
        let value: String?
        switch view {
        case let label as UILabel:
            value = label.text
        case let field as UITextField:
            value = field.isSecureTextEntry ? field.placeholder : field.text
        case let textView as UITextView:
            value = textView.text
        case let searchBar as UISearchBar:
            value = searchBar.text
        case let button as UIButton:
            value = button.currentTitle
        default:
            value = view.accessibilityLabel
        }

        guard let text = nonEmpty(value?.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        guard text.count > Constants.maxTextLength else { return text }
        return String(text.prefix(Constants.maxTextLength))
    }

    private static func isFrameworkChrome(_ view: UIView) -> Bool {
        Constants.chromeTypes.contains(SwiftUIIdentity.simpleTypeName(of: view))
    }

    /// Whether the view draws content, is interactive, or was given something to identify it by.
    ///
    /// Anonymous containers are deliberately excluded: this predicate decides the *initial* pick,
    /// and admitting a wrapper would let one outrank the targets that actually carry information.
    /// Broadening the selection uses `isBroadenable` instead.
    private static func carriesContent(
        _ view: UIView,
        accessibilityIdentifier: String?,
        accessibilityLabel: String?
    ) -> Bool {
        if accessibilityIdentifier != nil { return true }
        if view is UILabel || view is UIImageView || view is UIControl || view is UITextView { return true }
        if view is UIProgressView || view is UIActivityIndicatorView { return true }
        if SwiftUIIdentity.isHostingView(view) { return true }
        if view.isUserInteractionEnabled, let recognizers = view.gestureRecognizers, !recognizers.isEmpty {
            return true
        }
        // A custom view that presents itself as a single accessibility element is content as
        // far as the user is concerned, even though it is none of the classes above.
        return view.isAccessibilityElement && accessibilityLabel != nil
    }
}

#endif
