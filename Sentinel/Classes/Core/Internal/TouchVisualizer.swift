//
//  TouchVisualizer.swift
//  Sentinel
//
//  Created by Karlo Čeh on 15/10/2026.
//

#if os(iOS)

import UIKit

/// Draws a circle under every touch so screen recordings show where the user tapped.
final class TouchVisualizer {

    // MARK: - Internal properties

    static let shared = TouchVisualizer()

    /// Turning it on installs the `sendEvent(_:)` hook the first time. Turning it off removes the indicators of touches in progress.
    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            userDefaults.set(isEnabled, forKey: Self.userDefaultsKey)
            if isEnabled {
                UIWindow.installTouchVisualizerHook
            } else {
                removeAllIndicators()
            }
        }
    }

    // MARK: - Private properties

    private static let userDefaultsKey = "com.infinum.sentinel.showTouches"

    private let userDefaults: UserDefaults
    private var indicators: [ObjectIdentifier: UIView] = [:]

    // MARK: - Lifecycle

    /// Tests pass their own defaults; the app uses `shared`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        isEnabled = userDefaults.bool(forKey: Self.userDefaultsKey)
    }

    // MARK: - Internal methods

    /// Installs the hook if the toggle was left on in a previous launch.
    func restore() {
        guard isEnabled else { return }
        UIWindow.installTouchVisualizerHook
    }

    func handle(_ touches: Set<UITouch>, in window: UIWindow) {
        for touch in touches {
            handleTouch(
                ObjectIdentifier(touch),
                phase: touch.phase,
                at: touch.location(in: window),
                in: window
            )
        }
    }

    /// One touch of `handle(_:in:)`, split out because tests can't create a `UITouch`.
    func handleTouch(
        _ id: ObjectIdentifier,
        phase: UITouch.Phase,
        at location: CGPoint,
        in window: UIWindow
    ) {
        switch phase {
        case .began:
            indicators[id]?.removeFromSuperview()
            let indicator = makeIndicator(for: window)
            indicator.center = location
            window.addSubview(indicator)
            indicators[id] = indicator
        case .moved:
            indicators[id]?.center = location
        case .ended, .cancelled:
            guard let indicator = indicators.removeValue(forKey: id) else { return }
            fadeOut(indicator)
        default:
            break
        }
    }

    /// The indicator drawn for a touch still in progress.
    func indicator(for id: ObjectIdentifier) -> UIView? {
        indicators[id]
    }
}

// MARK: - Private methods

private extension TouchVisualizer {

    func makeIndicator(for window: UIWindow) -> UIView {
        let indicator = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        indicator.isUserInteractionEnabled = false
        indicator.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        indicator.layer.cornerRadius = 22
        indicator.layer.borderWidth = 3
        indicator.layer.borderColor = UIColor.systemBlue.resolvedColor(with: window.traitCollection).cgColor
        // Draws above views added to the window later, e.g. a sheet presented while the finger is held.
        indicator.layer.zPosition = 1_000
        return indicator
    }

    func fadeOut(_ indicator: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            indicator.alpha = 0
            indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            indicator.removeFromSuperview()
        }
    }

    func removeAllIndicators() {
        indicators.values.forEach { $0.removeFromSuperview() }
        indicators.removeAll()
    }
}

// MARK: - UIWindow swizzle

extension UIWindow {

    static let installTouchVisualizerHook: Void = {
        guard let originalMethod = class_getInstanceMethod(UIWindow.self, #selector(UIWindow.sendEvent(_:))),
              let swizzledMethod = class_getInstanceMethod(UIWindow.self, #selector(UIWindow.sentinel_sendEvent(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    // Not `swizzled_`, unlike `Trigger.swift`: ShowTime adds `swizzled_sendEvent(_:)` to `UIWindow`,
    // and two categories with the same selector would undo each other's exchange.
    @objc func sentinel_sendEvent(_ event: UIEvent) {
        sentinel_sendEvent(event) // original implementation, always first
        guard TouchVisualizer.shared.isEnabled, event.type == .touches else { return }
        TouchVisualizer.shared.handle(event.touches(for: self) ?? [], in: self)
    }
}

#endif
