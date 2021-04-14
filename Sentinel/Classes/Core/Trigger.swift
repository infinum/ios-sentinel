//
//  Trigger.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

/// Defines interaction with trigger.
@objc
public protocol Trigger: NSObjectProtocol {

    /// Subscribes to the triggering event.
    ///
    /// - Parameter events: The block which will be called when notification arrives.
    @objc(subscribeOnEvents:)
    func subscribe(on events: @escaping () -> ())
}

/// Provides different trigger types based on the event which makes the trigger.
@objcMembers
public class Triggers: NSObject {
    
    // MARK: - Public triggers
    
    /// The trigger type which is triggered on the shake event.
    public static var shake: Trigger { ShakeTrigger() }
    
    /// The trigger type which is triggered on the screenshot event.
    public static var screenshot: Trigger { ScreenshotTrigger() }
    
    /// The trigger type which is triggered on the specified notification name.
    @objc(notificationForName:)
    public static func notification(forName name: Notification.Name) -> Trigger {
        NotificationTrigger(notificationName: name)
    }
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
}

/// Defines trigger which is triggered when on the notification event.
@objcMembers
public class NotificationTrigger: NSObject, Trigger {

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
        super.init()
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

/// Defines trigger which is triggered when on the screenshot event.
@objcMembers
public class ScreenshotTrigger: NSObject, Trigger {
    
    // MARK: - Public properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the screenshot trigger.
    public override init() {
        notificationTrigger = NotificationTrigger(notificationName: UIApplication.userDidTakeScreenshotNotification)
        super.init()
    }
    
    // MARK: - Public methods

    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

/// Defines trigger which is triggered when on the shake event.
@objcMembers
public class ShakeTrigger: NSObject, Trigger {
    
    // MARK: - Public properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
    /// Creates an instance of the shake trigger.
    public override init() {
        UIApplication.classInit
        notificationTrigger = NotificationTrigger(notificationName: .shakeMotionDetected)
        super.init()
    }
    
    // MARK: - Public methods
    
    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

// MARK: - Internal -

extension Notification.Name {

    /// The notification name for shake event.
    static var shakeMotionDetected: Notification.Name { .init("toolbox_shake_motion_detected") }
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
