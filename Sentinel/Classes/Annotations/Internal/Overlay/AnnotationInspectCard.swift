//
//  AnnotationInspectCard.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import UIKit

/// The compact card that names the selected element and offers "Add note".
///
/// Positioned just below the selection, flipped above it when there is no room, and clamped to
/// the viewport so it is never partly off screen.
final class AnnotationInspectCard: UIView, SentinelOverlayView {

    // MARK: - Internal properties

    var onAddNote: (() -> Void)?

    // MARK: - Private properties

    private enum Constants {
        static let margin: CGFloat = 12
        static let gap: CGFloat = 12
        static let maxWidth: CGFloat = 320
        static let cornerRadius: CGFloat = 10
        static let contentInset: CGFloat = 12
        static let spacing: CGFloat = 8
    }

    private let typeLabel = UILabel()
    private let detailLabel = UILabel()
    private let addNoteButton = UIButton(type: .system)
    private let stack = UIStackView()

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        setupViews()
        isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    /// Shows the card for `node`, positioned against `anchor` inside `viewport`. Both rectangles
    /// are in the card's superview coordinate space.
    func show(for node: TargetNode, anchor: CGRect, in viewport: CGRect) {
        typeLabel.text = node.type
        // UIKit views identify by accessibility identifier, SwiftUI ones by their hosting type.
        // Show whichever resolved, then the element's text. SwiftUI-drawn content has none of
        // those, so it falls back to the size, which at least confirms what was selected.
        detailLabel.text = node.accessibilityIdentifier
            ?? node.swiftUIType
            ?? node.text
            ?? Self.sizeDescription(of: node.screenFrame)
        detailLabel.isHidden = detailLabel.text?.isEmpty != false
        isHidden = false

        // Width is fixed first and fed back in at `.required` priority, so the labels wrap
        // against the width the card will actually get and the measured height matches it.
        let width = max(min(Constants.maxWidth, viewport.width - Constants.margin * 2), 0)
        let height = systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let size = CGSize(width: width, height: height)

        let below = anchor.maxY + Constants.gap
        let above = anchor.minY - Constants.gap - size.height
        let originY: CGFloat
        if below + size.height <= viewport.maxY - Constants.margin {
            originY = below
        } else if above >= viewport.minY + Constants.margin {
            originY = above
        } else {
            originY = max(viewport.maxY - size.height - Constants.margin, viewport.minY + Constants.margin)
        }

        let maxOriginX = max(viewport.maxX - size.width - Constants.margin, Constants.margin)
        let originX = min(max(anchor.minX, viewport.minX + Constants.margin), maxOriginX)

        frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
    }

    func hide() {
        isHidden = true
    }

    // MARK: - Private methods

    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor

        typeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        typeLabel.textColor = .label
        typeLabel.numberOfLines = 1

        detailLabel.font = .systemFont(ofSize: 12, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 2

        addNoteButton.setTitle("Add note", for: .normal)
        addNoteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        addNoteButton.contentHorizontalAlignment = .leading
        addNoteButton.addTarget(self, action: #selector(handleAddNote), for: .touchUpInside)

        stack.axis = .vertical
        stack.spacing = Constants.spacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        [typeLabel, detailLabel, addNoteButton].forEach(stack.addArrangedSubview)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentInset),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.contentInset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.contentInset),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.contentInset)
        ])
    }

    @objc private func handleAddNote() {
        onAddNote?()
    }

    private static func sizeDescription(of frame: CGRect) -> String? {
        guard !frame.isEmpty else { return nil }
        return "\(Int(frame.width.rounded())) × \(Int(frame.height.rounded())) pt"
    }
}

#endif
