//
//  AnnotationStopButton.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// The draggable control that ends capture.
///
/// The Flutter library this feature is ported from turns its floating debug button into a close
/// button while capture runs. Sentinel is triggered by a shake rather than a button, so capture
/// brings its own control. A long press reopens the Sentinel panel with capture still armed,
/// matching that behaviour.
final class AnnotationStopButton: UIButton, SentinelOverlayView {

    // MARK: - Internal properties

    var onStop: (() -> Void)?
    var onReopen: (() -> Void)?

    static let size: CGFloat = 44

    // MARK: - Private properties

    private var dragOrigin: CGPoint = .zero

    private let longPressRecognizer = UILongPressGestureRecognizer()

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Self.size, height: Self.size))
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupViews() {
        setImage(UIImage(systemName: "xmark"), for: .normal)
        tintColor = .white
        backgroundColor = UIColor(red: 0.90, green: 0.14, blue: 0.45, alpha: 1)
        layer.cornerRadius = Self.size / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        accessibilityLabel = "Stop annotating"

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)

        longPressRecognizer.addTarget(self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressRecognizer)
    }

    @objc private func handleTap() {
        onStop?()
    }

    /// Drags follow the finger, clamped to the parent so the control can never be parked
    /// off screen where it could no longer be used to stop capture.
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let container = superview else { return }

        switch recognizer.state {
        case .began:
            dragOrigin = center
            // Both the tap and the long press are attached to this same button, and neither is
            // meant to fire because of a drag: the finger stays inside the control the whole way
            // (it moves with it), and a slow drag would otherwise outlast the long-press timeout
            // and reopen the Sentinel panel mid-drag.
            cancelTracking(with: nil)
            longPressRecognizer.isEnabled = false
        case .changed, .ended:
            let translation = recognizer.translation(in: container)
            let bounds = container.bounds.inset(by: container.safeAreaInsets)
            center = CGPoint(
                x: min(max(dragOrigin.x + translation.x, bounds.minX + Self.size / 2), bounds.maxX - Self.size / 2),
                y: min(max(dragOrigin.y + translation.y, bounds.minY + Self.size / 2), bounds.maxY - Self.size / 2)
            )
            if recognizer.state == .ended {
                longPressRecognizer.isEnabled = true
            }
        case .cancelled, .failed:
            longPressRecognizer.isEnabled = true
        default:
            break
        }
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        onReopen?()
    }
}

#endif
