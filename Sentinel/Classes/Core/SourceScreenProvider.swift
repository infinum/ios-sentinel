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
        controller.view.frame = .init(x: 0, y: 0, width: 1200, height: 800)
        keyWindow?.contentViewController?.presentAsModalWindow(controller)
    }
    #else
    
    public func showTools(for view: some View) {
        topMostController()?.present(UIHostingController(rootView: view), animated: true)
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
