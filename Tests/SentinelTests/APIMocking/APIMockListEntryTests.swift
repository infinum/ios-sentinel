//
//  APIMockListEntryTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Testing
@testable import Sentinel

@Suite("API mock list entries")
struct APIMockListEntryTests {

    @Test("Mocks without a group are listed on their own, in order")
    func ungrouped() {
        let first = mock("First")
        let second = mock("Second")

        #expect(APIMockListEntry.entries(for: [first, second]) == [.mock(first), .mock(second)])
    }

    @Test("Mocks sharing a group are listed together, where the group's first mock is")
    func grouped() {
        let products = mock("Products", group: "Catalog")
        let login = mock("Login")
        let categories = mock("Categories", group: "Catalog")
        let orders = mock("Orders", group: "Checkout")

        #expect(APIMockListEntry.entries(for: [products, login, categories, orders]) == [
            .group(name: "Catalog", mocks: [products, categories]),
            .mock(login),
            .group(name: "Checkout", mocks: [orders])
        ])
    }

    @Test("A blank group name is no group, and names are trimmed")
    func blankGroups() {
        let blank = mock("Blank", group: "  ")
        let padded = mock("Padded", group: " Catalog ")
        let plain = mock("Plain", group: "Catalog")

        #expect(APIMockListEntry.entries(for: [blank, padded, plain]) == [
            .mock(blank),
            .group(name: "Catalog", mocks: [padded, plain])
        ])
    }
}

// MARK: - Helpers

private extension APIMockListEntryTests {

    func mock(_ name: String, group: String? = nil) -> APIMock {
        APIMock(
            name: name,
            group: group,
            url: .wildcard("/\(name.lowercased())"),
            body: .json("{}")
        )
    }
}
