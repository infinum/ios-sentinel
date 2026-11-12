//
//  StackTraceTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.10.2026..
//

import Testing
@testable import Sentinel

@Suite("Stack trace parsing")
struct StackTraceTests {

    // Pins current behaviour: the greedy `\$s(\S+)\d+` pattern captures everything up to the last digit
    // of the mangled name, not a demangled class name.
    @Test(
        "Class names are read from mangled Swift symbols",
        arguments: [
            ("3   Example   0x0000000100001234 $s7Example14ViewControllerC6buttonyyF + 52", "7Example14ViewControllerC"),
            ("1   Sentinel  0x0000000104a1b2c3 $s8Sentinel0A0C5setup4withyAC13ConfigurationV_tF + 120", "8Sentinel0A0C5setup4withyAC1")
        ]
    )
    func classNames(symbol: String, expected: String) {
        #expect(StackTrace.classNameFromSymbol(symbol) == expected)
    }

    @Test(
        "Symbols without a Swift mangling have no class name",
        arguments: [
            "0   CoreFoundation   0x00000001804ba90c __exceptionPreprocess + 172",
            "2   libsystem_c.dylib 0x0000000180123456 abort + 180",
            ""
        ]
    )
    func noClassName(symbol: String) {
        #expect(StackTrace.classNameFromSymbol(symbol) == nil)
    }

    @Test("File, line and function are read from symbolicated frames")
    func fileInfo() throws {
        let symbol = "4   Example   0x0000000100001234 ViewController.swift:42 didTapButton(_:) + 52"

        let info = try #require(StackTrace.fileInfoFromSymbol(symbol))

        #expect(info.file == "ViewController.swift")
        #expect(info.line == 42)
        #expect(info.function == "didTapButton(")
    }

    @Test(
        "Frames without file information have none",
        arguments: [
            "0   CoreFoundation   0x00000001804ba90c __exceptionPreprocess + 172",
            "4   Example   0x0000000100001234 ViewController.m:42 didTapButton + 52",
            ""
        ]
    )
    func noFileInfo(symbol: String) {
        #expect(StackTrace.fileInfoFromSymbol(symbol) == nil)
    }

    @Test("Binary information lists the loaded images")
    func binaryInformation() {
        #expect(!StackTrace.binaryInformation().isEmpty)
    }
}
