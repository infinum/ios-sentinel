//
//  Trigger.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

#if canImport(UIKit)
import UIKit
#endif

/// Defines interaction with trigger.
public protocol Trigger {

    /// Subscribes to the triggering event.
    ///
    /// - Parameter events: The block which will be called when notification arrives.
    func subscribe(on events: @escaping () -> ())
}

/// Provides different trigger types based on the event which makes the trigger.
public enum Triggers {


    /// The trigger type which is triggered on the specified notification name.
    public static func notification(forName name: Notification.Name) -> Trigger {
        NotificationTrigger(notificationName: name)
    }
    #if !os(macOS)
    /// The trigger type which is triggered on the shake event.
    public static var shake: Trigger { ShakeTrigger() }

    /// The trigger type which is triggered on the screenshot event.
    public static var screenshot: Trigger { ScreenshotTrigger() }
    #endif
}

/// Defines trigger which is triggered when on the notification event.
public final class NotificationTrigger: Trigger {

    // MARK: - Private properties
    
    private var observer: (() -> ())?
    private var observerToken: NSObjectProtocol?
    private let notificationName: Notification.Name
    private let queue: OperationQueue

    // MARK: - Lifecycle
    
    /// Creates an instance of the notification trigger.
    ///
    /// - Parameters:
    ///     - notificationName: The string used for observing notification.
    ///     - queue: The operation queue type used for observing notifications.
    public init(notificationName: Notification.Name, queue: OperationQueue = .main) {
        self.notificationName = notificationName
        self.queue = queue
        setup()
    }
    
    deinit {
        guard let token = observerToken else { return }
        NotificationCenter.default.removeObserver(token)
    }

    // MARK: - Public methods
    
    public func subscribe(on events: @escaping () -> ()) {
        observer = events
    }
    
    // MARK: - Private methods

    private func setup() {
        observerToken = NotificationCenter.default.addObserver(
            forName: notificationName,
            object: nil,
            queue: queue,
            using: { [weak self] _ in self?.observer?() }
        )
    }
    
}

// MARK: - Internal -

extension Notification.Name {

    /// The notification name for shake event.
    static var shakeMotionDetected: Notification.Name { .init("sentinel_shake_motion_detected") }
}

#if canImport(UIKit)

/// Defines trigger which is triggered when on the screenshot event.
public final class ScreenshotTrigger: Trigger {

    // MARK: - Internal properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the screenshot trigger.
    public init() {
        notificationTrigger = NotificationTrigger(notificationName: UIApplication.userDidTakeScreenshotNotification)
    }
    
    // MARK: - Public methods

    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

/// Defines trigger which is triggered when on the shake event.
public final class ShakeTrigger: Trigger {

    // MARK: - Internal properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the shake trigger.
    public init() {
        UIApplication.classInit
        notificationTrigger = NotificationTrigger(notificationName: .shakeMotionDetected)
    }
    
    // MARK: - Public methods
    
    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

extension UIApplication {
    
    static let classInit: Void = {
        guard let originalMethod = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.motionEnded(_:with:))),
              let swizzledMethod = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.swizzled_motionEnded(_:with:)))
        else { return }
       method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    
    @objc func swizzled_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        swizzled_motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .shakeMotionDetected, object: nil)
        }
    }
}
#endif
