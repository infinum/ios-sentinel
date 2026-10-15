//
//  NotificationTriggerTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Foundation
import Testing
@testable import Sentinel
#if os(iOS)
import UIKit
#endif

@Suite("Notification trigger")
struct NotificationTriggerTests {

    // Tests run in parallel, so every test observes its own notification name.
    private let name = Notification.Name("sentinel.tests.\(UUID().uuidString)")

    @Test("Posting the observed notification calls the subscriber")
    func postingCallsSubscriber() async {
        let trigger = NotificationTrigger(notificationName: name, queue: OperationQueue())

        await confirmation { fired in
            trigger.subscribe { fired() }
            NotificationCenter.default.post(name: name, object: nil)
            await waitForDelivery()
        }
    }

    @Test("Other notifications don't call the subscriber")
    func otherNotificationsAreIgnored() async {
        let trigger = NotificationTrigger(notificationName: name, queue: OperationQueue())

        await confirmation(expectedCount: 0) { fired in
            trigger.subscribe { fired() }
            NotificationCenter.default.post(name: Notification.Name("sentinel.tests.other.\(UUID().uuidString)"), object: nil)
            await waitForDelivery()
        }
    }

    @Test("A deallocated trigger stops observing")
    func deallocatedTriggerStopsObserving() async {
        await confirmation(expectedCount: 0) { fired in
            var trigger: NotificationTrigger? = NotificationTrigger(notificationName: name, queue: OperationQueue())
            trigger?.subscribe { fired() }
            trigger = nil
            NotificationCenter.default.post(name: name, object: nil)
            await waitForDelivery()
        }
    }

    @Test("Triggers.notification(forName:) creates a notification trigger")
    func factoryCreatesNotificationTrigger() {
        #expect(Triggers.notification(forName: name) is NotificationTrigger)
    }

    #if os(iOS)
    @Test("Screenshot trigger fires on the screenshot notification")
    @MainActor
    func screenshotTriggerFires() async {
        let trigger = ScreenshotTrigger()

        await confirmation { fired in
            trigger.subscribe { fired() }
            NotificationCenter.default.post(name: UIApplication.userDidTakeScreenshotNotification, object: nil)
            await waitForDelivery()
        }
    }
    #endif
}

private extension NotificationTriggerTests {

    /// Gives an `OperationQueue` (or the main queue) time to deliver a posted notification.
    func waitForDelivery() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
}
