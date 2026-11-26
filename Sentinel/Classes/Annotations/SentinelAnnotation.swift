//
//  SentinelAnnotation.swift
//  Sentinel
//
//  Created by Sentinel on 07/09/2026.
//

// Annotation capture is UIKit based. Package.swift cannot exclude a directory per
// platform — its `#if os(iOS)` is evaluated on the build host — so the guard lives here.
#if canImport(UIKit)

import CoreGraphics
import Foundation

/// A note attached to an element captured on the running app.
///
/// Every property in the `CodingKeys` list below is part of the export payload a Claude Code
/// routine reads to locate the element in source. `rebindPoint` and `isSent` are Sentinel's own
/// bookkeeping and are deliberately left out of it.
///
/// The live handle to the annotated view is *not* stored here. It lives in `AnnotationStore`
/// as a weak reference keyed by ``id``, so a saved note can never keep a dismissed view
/// controller's view hierarchy alive.
public struct SentinelAnnotation: Identifiable, Equatable, Encodable, Sendable {

    // MARK: - Public properties

    /// Session-unique id assigned by the store. Links a fix back to its note.
    public internal(set) var id: String

    /// The free-text note the user typed.
    public internal(set) var note: String

    /// Which toolkit the target belongs to.
    public let toolkit: AnnotationToolkit

    /// View class name, without its module prefix — `UIButton`, `CGDrawingView`.
    public let targetType: String

    /// Ancestor chain, broadest first, e.g. `UIStackView>UIControl>UILabel`.
    public let targetPath: String

    /// The element's accessibility identifier, greppable as `accessibilityIdentifier("x")` in
    /// SwiftUI and `accessibilityIdentifier = "x"` in UIKit. The single strongest locator on iOS.
    public let accessibilityIdentifier: String?

    /// The element's accessibility label. Often the only signal a SwiftUI leaf carries.
    public let accessibilityLabel: String?

    /// The app's own SwiftUI view type hosting this element, recovered from the generic
    /// parameter of the enclosing `_UIHostingView` or `UIHostingController`. `nil` for UIKit.
    public let swiftUIType: String?

    /// 1-based position among same-type elements on the screen, top to bottom then left to right.
    public let ordinal: Int

    /// Total count of same-type elements on the screen — the `M` in "N of M".
    public let ordinalCount: Int

    /// Visible text, used to disambiguate identical siblings. Never the contents of a secure
    /// text field.
    public let text: String?

    /// Class name of the topmost presented view controller — the screen the user was looking at.
    public let screen: String?

    /// Class name of the deepest view controller whose view contains the target.
    public let viewController: String?

    /// The element's rectangle on screen, in points, when it was captured.
    ///
    /// Part of the payload because it is the only geometric signal a note carries, and for
    /// SwiftUI-drawn content — which has no identifier and no text — it is most of what
    /// distinguishes one element from another beyond ``ordinal``.
    public let bounds: ElementBounds

    // MARK: - Internal bookkeeping, not exported

    /// Screen coordinates of the target's centre when captured. Anchors re-binding after the
    /// view hierarchy is recreated.
    public let rebindPoint: CGPoint

    /// Whether this note has already been exported.
    public internal(set) var isSent: Bool

    // MARK: - Lifecycle

    public init(
        id: String = "",
        note: String,
        toolkit: AnnotationToolkit,
        targetType: String,
        targetPath: String,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        swiftUIType: String? = nil,
        ordinal: Int = 1,
        ordinalCount: Int = 1,
        text: String? = nil,
        screen: String? = nil,
        viewController: String? = nil,
        bounds: ElementBounds = ElementBounds(),
        rebindPoint: CGPoint = .zero,
        isSent: Bool = false
    ) {
        self.id = id
        self.note = note
        self.toolkit = toolkit
        self.targetType = targetType
        self.targetPath = targetPath
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.swiftUIType = swiftUIType
        self.ordinal = ordinal
        self.ordinalCount = ordinalCount
        self.text = text
        self.screen = screen
        self.viewController = viewController
        self.bounds = bounds
        self.rebindPoint = rebindPoint
        self.isSent = isSent
    }
}

// MARK: - Encoding

public extension SentinelAnnotation {

    enum CodingKeys: String, CodingKey {
        case id
        case note
        case toolkit
        case targetType
        case targetPath
        case accessibilityIdentifier
        case accessibilityLabel
        case swiftUIType
        case ordinal
        case ordinalCount
        case text
        case screen
        case viewController
        case bounds
    }

    /// Writes every key, `null` included.
    ///
    /// `encodeIfPresent` would drop the unresolved ones, and a routine reading the payload
    /// benefits from seeing that a locator was looked for and did not resolve, rather than
    /// having to guess whether the key is missing or the value is absent.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(note, forKey: .note)
        try container.encode(toolkit, forKey: .toolkit)
        try container.encode(targetType, forKey: .targetType)
        try container.encode(targetPath, forKey: .targetPath)
        try container.encode(accessibilityIdentifier, forKey: .accessibilityIdentifier)
        try container.encode(accessibilityLabel, forKey: .accessibilityLabel)
        try container.encode(swiftUIType, forKey: .swiftUIType)
        try container.encode(ordinal, forKey: .ordinal)
        try container.encode(ordinalCount, forKey: .ordinalCount)
        try container.encode(text, forKey: .text)
        try container.encode(screen, forKey: .screen)
        try container.encode(viewController, forKey: .viewController)
        try container.encode(bounds, forKey: .bounds)
    }

    /// The default export payload for a batch: a JSON array of annotation objects.
    static func exportJSON(for annotations: [SentinelAnnotation]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = try encoder.encode(annotations)
        guard let json = String(data: data, encoding: .utf8) else {
            throw AnnotationExportError.encodingFailed
        }
        return json
    }

    /// The default export payload for a single annotation.
    func exportJSON() throws -> String {
        try Self.exportJSON(for: [self])
    }
}

// MARK: - Bounds

/// An element's rectangle on screen, in points.
public struct ElementBounds: Encodable, Equatable, Sendable {

    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double = 0, y: Double = 0, width: Double = 0, height: Double = 0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    init(_ rect: CGRect) {
        self.init(
            x: rect.origin.x.rounded(),
            y: rect.origin.y.rounded(),
            width: rect.size.width.rounded(),
            height: rect.size.height.rounded()
        )
    }
}

// MARK: - Errors

/// Failures raised by the built-in exporters and by ``SentinelAnnotation/exportJSON()``.
public enum AnnotationExportError: LocalizedError {

    /// The encoded payload was not valid UTF-8.
    case encodingFailed

    /// ``ClaudeRoutineExporter`` was given no token, so the request was never made.
    case missingToken

    /// ``ClaudeRoutineExporter``'s `fireUrl` is not a valid URL.
    case invalidURL(String)

    /// The routine endpoint answered with a non-2xx status.
    case requestFailed(statusCode: Int, body: String)

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Could not encode the annotations"
        case .missingToken:
            return "No Claude token configured"
        case .invalidURL(let url):
            return "Invalid fire URL: \(url)"
        case .requestFailed(let statusCode, let body):
            return "Failed to send annotations to Claude (HTTP \(statusCode)): \(body)"
        }
    }
}

#endif
