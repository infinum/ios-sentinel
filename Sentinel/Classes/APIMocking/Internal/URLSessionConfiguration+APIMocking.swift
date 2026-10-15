//
//  URLSessionConfiguration+APIMocking.swift
//  Sentinel
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation

extension URLSessionConfiguration {

    /// Makes every `default` and `ephemeral` configuration created from now on, and `URLSession.shared`,
    /// go through the mocking protocol. Runs once.
    static let installAPIMocking: Void = {
        exchangeClassGetter(
            #selector(getter: URLSessionConfiguration.default),
            with: #selector(getter: URLSessionConfiguration.sentinel_apiMockingDefault)
        )
        exchangeClassGetter(
            #selector(getter: URLSessionConfiguration.ephemeral),
            with: #selector(getter: URLSessionConfiguration.sentinel_apiMockingEphemeral)
        )
        // `URLSession.shared` doesn't take a configuration from the app; it uses the registered classes.
        URLProtocol.registerClass(APIMockingURLProtocol.self)
    }()

    /// Puts the mocking protocol first, unless the configuration already has it.
    func addAPIMocking() {
        let classes = protocolClasses ?? []
        guard !classes.contains(where: { $0 == APIMockingURLProtocol.self }) else { return }
        protocolClasses = [APIMockingURLProtocol.self] + classes
    }
}

private extension URLSessionConfiguration {

    static func exchangeClassGetter(_ original: Selector, with replacement: Selector) {
        guard let originalMethod = class_getClassMethod(URLSessionConfiguration.self, original),
              let replacementMethod = class_getClassMethod(URLSessionConfiguration.self, replacement)
        else { return }
        method_exchangeImplementations(originalMethod, replacementMethod)
    }

    // Once exchanged, these getters call the original implementations under their own names. `dynamic`
    // keeps those calls going through the Objective-C runtime, which is what makes them reach the originals.

    @objc dynamic class var sentinel_apiMockingDefault: URLSessionConfiguration {
        let configuration = self.sentinel_apiMockingDefault
        configuration.addAPIMocking()
        return configuration
    }

    @objc dynamic class var sentinel_apiMockingEphemeral: URLSessionConfiguration {
        let configuration = self.sentinel_apiMockingEphemeral
        configuration.addAPIMocking()
        return configuration
    }
}
