//
//  AnnotationOverlayView.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// The layer that draws saved notes over the running app and, while capture is armed, takes
/// every touch so a tap selects an element instead of operating the app.
///
/// Markers are painted on one canvas rather than built as child views: this layer redraws
/// whenever the app scrolls, and a single draw pass is far cheaper than a view hierarchy.
final class AnnotationOverlayView: UIView, SentinelOverlayView {

    // MARK: - Internal properties

    /// While `true` this layer swallows every touch and taps select elements.
    var isCaptureActive = false {
        didSet {
            guard oldValue != isCaptureActive else { return }
            setNeedsDisplay()
        }
    }

    var markers: [AnnotationMarker] = [] {
        didSet {
            guard oldValue != markers else { return }
            setNeedsDisplay()
        }
    }

    /// Screen rectangle of the element currently selected in capture mode.
    var selection: CGRect? {
        didSet {
            guard oldValue != selection else { return }
            setNeedsDisplay()
        }
    }

    /// Called with the screen coordinates of a tap while capture is armed.
    var onCaptureTap: ((CGPoint) -> Void)?

    /// Called when a saved note's badge is tapped.
    var onBadgeTap: ((SentinelAnnotation) -> Void)?

    // MARK: - Private properties

    private enum Constants {
        static let markerColor = UIColor(red: 0.90, green: 0.14, blue: 0.45, alpha: 1)
        static let outlineWidth: CGFloat = 1.5
        static let selectionWidth: CGFloat = 3
        static let badgeSize: CGFloat = 20
        static let badgeFontSize: CGFloat = 12
    }

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        // Markers are drawn, not built as views, so there is nothing here to announce. Hiding
        // the layer from accessibility also stops a full-screen overlay from being reported as
        // the element at every point, which would otherwise put the host app's own content out
        // of reach of VoiceOver — and of UI tests — for as long as one note is on screen.
        isAccessibilityElement = false
        accessibilityElementsHidden = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: Constants.badgeFontSize, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        markers.forEach { marker in
            let frame = convertFromScreen(marker.screenFrame)

            context.setStrokeColor(Constants.markerColor.cgColor)
            context.setLineWidth(Constants.outlineWidth)
            context.stroke(frame)

            let badge = CGRect(
                x: frame.minX,
                y: frame.minY,
                width: Constants.badgeSize,
                height: Constants.badgeSize
            )
            context.setFillColor(Constants.markerColor.cgColor)
            context.fill(badge)

            let number = "\(marker.number)" as NSString
            let size = number.size(withAttributes: attributes)
            number.draw(
                at: CGPoint(
                    x: badge.midX - size.width / 2,
                    y: badge.midY - size.height / 2
                ),
                withAttributes: attributes
            )
        }

        guard let selection = selection else { return }
        context.setStrokeColor(Constants.markerColor.cgColor)
        context.setLineWidth(Constants.selectionWidth)
        context.stroke(convertFromScreen(selection))
    }

    // MARK: - Touch handling

    /// Capture mode consumes everything. Passive mode consumes only a badge tap, so the app
    /// underneath stays fully usable while saved notes remain editable.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isCaptureActive {
            return bounds.contains(point)
        }
        return marker(at: point) != nil
    }

    // MARK: - Private methods

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        if let marker = marker(at: point) {
            onBadgeTap?(marker.annotation)
            return
        }
        guard isCaptureActive else { return }
        onCaptureTap?(convertToScreen(point))
    }

    /// The saved note whose badge square covers `point`, most recently added first so the
    /// topmost badge wins.
    private func marker(at point: CGPoint) -> AnnotationMarker? {
        markers.last { marker in
            let frame = convertFromScreen(marker.screenFrame)
            return CGRect(
                x: frame.minX,
                y: frame.minY,
                width: Constants.badgeSize,
                height: Constants.badgeSize
            ).contains(point)
        }
    }

    private func convertFromScreen(_ rect: CGRect) -> CGRect {
        let origin = sentinelScreenFrame.origin
        return rect.offsetBy(dx: -origin.x, dy: -origin.y)
    }

    private func convertToScreen(_ point: CGPoint) -> CGPoint {
        let origin = sentinelScreenFrame.origin
        return CGPoint(x: point.x + origin.x, y: point.y + origin.y)
    }
}

#endif
