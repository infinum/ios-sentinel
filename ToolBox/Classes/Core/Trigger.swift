//
//  Trigger.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

@objc
public protocol Trigger: NSObjectProtocol {
    func subscribe(on events: @escaping () -> ())
}

@objcMembers
public class Triggers: NSObject {
    
    // MARK: - Public triggers
    
    public static var shake: Trigger { ShakeTrigger() }
    public static var screenshot: Trigger { ScreenshotTrigger() }
    public static func notification(forName name: Notification.Name) -> Trigger {
        NotificationTrigger(notificationName: name)
    }
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
    }
}

@objcMembers
public class NotificationTrigger: NSObject, Trigger {

    // MARK: - Private properties
    
    private var observer: (() -> ())?
    private let notificationName: Notification.Name
    private let queue: OperationQueue

    // MARK: - Lifecycle
    
    public init(notificationName: Notification.Name, queue: OperationQueue = .main) {
        self.notificationName = notificationName
        self.queue = queue
        super.init()
        setup()
    }
    
    // MARK: - Public methods
    
    public func subscribe(on events: @escaping () -> ()) {
        self.observer = events
    }
    
    // MARK: - Private methods

    private func setup() {
        NotificationCenter.default.addObserver(
            forName: notificationName,
            object: nil,
            queue: queue,
            using: { [weak self] _ in self?.observer?() }
        )
    }
    
}

@objcMembers
public class ScreenshotTrigger: NSObject, Trigger {
    
    // MARK: - Public properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
    public override init() {
        notificationTrigger = NotificationTrigger(notificationName: UIApplication.userDidTakeScreenshotNotification)
        super.init()
    }
    
    // MARK: - Public methods
    
    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

@objcMembers
public class ShakeTrigger: NSObject, Trigger {
    
    // MARK: - Public properties
    
    let notificationTrigger: NotificationTrigger
    
    // MARK: - Lifecycle
    
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
