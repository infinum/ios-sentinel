//
//  Trigger.swift
//  ToolBox
//
//  Created by Vlaho Poluta on 30/07/2020.
//

import UIKit

public protocol Trigger {
    func subscribe(on events: @escaping () -> ())
}

public enum Triggers {
    public static var shake: Trigger { ShakeTrigger() }
    public static var screenshot: Trigger { ScreenshotTrigger() }
    public static func notification(forName name: Notification.Name) -> Trigger {
        NotificationTrigger(notificationName: name)
    }
}

public class NotificationTrigger: Trigger {
    
    private var observer: (() -> ())?
    private let notificationName: Notification.Name
    private let queue: OperationQueue

    public init(notificationName: Notification.Name, queue: OperationQueue = .main) {
        self.notificationName = notificationName
        self.queue = queue
        setup()
    }
    
    public func subscribe(on events: @escaping () -> ()) {
        self.observer = events
    }

    private func setup() {
        NotificationCenter.default.addObserver(
            forName: notificationName,
            object: nil,
            queue: queue,
            using: { [weak self] _ in self?.observer?() }
        )
    }
    
}

public class ScreenshotTrigger: Trigger {
    
    let notificationTrigger: NotificationTrigger
    
    public init() {
        notificationTrigger = NotificationTrigger(notificationName: .UIApplicationUserDidTakeScreenshot)
    }
    
    public func subscribe(on events: @escaping () -> ()) {
        notificationTrigger.subscribe(on: events)
    }
}

public class ShakeTrigger: Trigger {
    
    let notificationTrigger: NotificationTrigger
    
    public init() {
        UIApplication.classInit
        notificationTrigger = NotificationTrigger(notificationName: .shakeMotionDetected)
    }
    
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
    
    @objc func swizzled_motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        swizzled_motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .shakeMotionDetected, object: nil)
        }
    }
}
