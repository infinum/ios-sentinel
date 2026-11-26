//
//  AnnotationOverlayViewController.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// Root view controller of ``AnnotationOverlayWindow``. Owns the marker canvas, the inspect card
/// and the stop control, and hosts the note sheet.
final class AnnotationOverlayViewController: UIViewController {

    // MARK: - Internal properties

    let overlayView = AnnotationOverlayView()
    let inspectCard = AnnotationInspectCard()
    let stopButton = AnnotationStopButton()

    // MARK: - Private properties

    private enum Constants {
        static let stopButtonMargin: CGFloat = 16
    }

    /// The stop control is draggable, so it is placed once and then left where the user put it.
    private var hasPlacedStopButton = false

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
        // The container itself carries nothing; only the controls added below should be
        // reachable. See `AnnotationOverlayView` for why this matters to the host app.
        view.isAccessibilityElement = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(inspectCard)
        view.addSubview(stopButton)
        stopButton.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasPlacedStopButton, !view.bounds.isEmpty else { return }
        hasPlacedStopButton = true

        let safe = view.bounds.inset(by: view.safeAreaInsets)
        stopButton.center = CGPoint(
            x: safe.maxX - AnnotationStopButton.size / 2 - Constants.stopButtonMargin,
            y: safe.maxY - AnnotationStopButton.size / 2 - Constants.stopButtonMargin
        )
    }
}

#endif
