//
//  ShakeTriggerIntegrationTests.swift
//  Sentinel_Tests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import ObjectiveC
import Testing
import UIKit
@testable import Sentinel

extension IntegrationTests {

    @Suite("Shake trigger")
    @MainActor
    struct ShakeTriggerIntegrationTests {

        @Test("A shake reaching the application fires the trigger")
        func shakeFiresTrigger() async {
            let trigger = Triggers.shake

            await confirmation { fired in
                trigger.subscribe { fired() }
                UIApplication.shared.motionEnded(.motionShake, with: nil)
                await Task.yield()
            }
        }

        @Test("Other motions don't fire the trigger")
        func otherMotionsAreIgnored() async {
            let trigger = Triggers.shake

            await confirmation(expectedCount: 0) { fired in
                trigger.subscribe { fired() }
                UIApplication.shared.motionEnded(.none, with: nil)
                await Task.yield()
            }
        }

        @Test("Swizzling only replaces UIApplication's implementation")
        func swizzleStaysOnUIApplication() throws {
            _ = ShakeTrigger()
            let selector = #selector(UIResponder.motionEnded(_:with:))

            let applicationMethod = try #require(class_getInstanceMethod(UIApplication.self, selector))
            let responderMethod = try #require(class_getInstanceMethod(UIResponder.self, selector))

            // If UIApplication didn't override motionEnded, the exchange would have swapped UIResponder's
            // implementation and every responder would call a selector only UIApplication has.
            #expect(method_getImplementation(applicationMethod) != method_getImplementation(responderMethod))
        }

        @Test("The screenshot trigger fires on a screenshot")
        func screenshotFiresTrigger() async {
            let trigger = Triggers.screenshot

            await confirmation { fired in
                trigger.subscribe { fired() }
                NotificationCenter.default.post(name: UIApplication.userDidTakeScreenshotNotification, object: nil)
                await Task.yield()
            }
        }
    }
}
