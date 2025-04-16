//
//  SourceScreenProvider.swift
//  Sentinel
//
//  Created by Vlaho Poluta on 30/07/2020.
//

//import UIKit
import SwiftUI

/// Defines source screen which will be used to present Sentinel when triggered.
public protocol SourceScreenProvider {

    /// The view controller used for presenting the Sentinel.
    func showTools(for view: some View)

    /// Checks if Sentinel is already shown
    func isShown() -> Bool

    /// Dismisses Sentinel, used if the user triggers the showing of Sentinel but it is already shown
    func dismiss()
}

/// Provides possible source screens used for presenting the Sentinel.
public enum SourceScreenProviders {

    // MARK: - Public providers
    
    /// Default source screen provider.
    public static var `default`: SourceScreenProvider { DefaultSourceScreenProvider() }
}

/// Defines default source screen provider used for presenting the Sentinel.
public struct DefaultSourceScreenProvider: SourceScreenProvider {

    // MARK: - Public properties

    #if os(macOS)
    public func showTools(for view: some View) {
        let keyWindow = NSApplication.shared.keyWindow
        let controller = NSHostingController(rootView: view)
        controller.view.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        keyWindow?.contentViewController?.presentAsModalWindow(controller)
    }

    public func isShown() -> Bool {
        NSApplication.shared.windows.compactMap(\.contentViewController).contains(where: { $0 is NSHostingController<SentinelTabBarView> })
    }

    public func dismiss() {
        NSApplication.shared.windows.first(where: { $0.contentViewController is NSHostingController<SentinelTabBarView> })?.close()
    }
    #else
    
    public func showTools(for view: some View) {
        topMostController()?.present(UIHostingController(rootView: view), animated: true)
    }

    public func isShown() -> Bool {
        topMostController() is UIHostingController<SentinelTabBarView>
    }

    public func dismiss() {
        topMostController()?.dismiss(animated: true)
    }

    // MARK: - Private methods

    private func topMostController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter(\.isKeyWindow)
                .first

        guard let window = keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
    #endif
}
