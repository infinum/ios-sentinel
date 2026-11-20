//
//  StackTraceFrameTests.swift
//  SentinelTests
//
//  Created by Nikola Simunko on 12.11.2026..
//

import Testing
@testable import Sentinel

@Suite("Stack trace image and symbol")
struct StackTraceFrameTests {

    @Test(
        "The image and symbol are read from a call stack line",
        arguments: [
            (
                "3   CoreFoundation                      0x0000000180a3d1f4 __exceptionPreprocess + 164",
                "CoreFoundation",
                "__exceptionPreprocess"
            ),
            (
                "12  Example-iOS                         0x0000000102684abc $s11Example_iOS4FeedC4loadyyF + 52",
                "Example-iOS",
                "$s11Example_iOS4FeedC4loadyyF"
            ),
            (
                "5   UIKitCore                           0x0000000185850123 -[UITableView _updateVisibleCellsNow:isRecursive:] + 2356",
                "UIKitCore",
                "-[UITableView _updateVisibleCellsNow:isRecursive:]"
            ),
            (
                "6   libc++abi.dylib                     0x00000001f021c010 std::__terminate(void (*)()) + 16",
                "libc++abi.dylib",
                "std::__terminate(void (*)())"
            )
        ]
    )
    func imageAndSymbol(title: String, image: String, symbol: String) {
        let trace = CrashModel.StackTrace(title: title, detail: "")

        #expect(trace.image == image)
        #expect(trace.symbol == symbol)
    }

    @Test("Only the frame index is dropped from an image whose name starts with a digit")
    func imageStartingWithDigit() {
        let trace = CrashModel.StackTrace(title: "4   1Password   0x0000000100001234 main + 64", detail: "")

        #expect(trace.image == "1Password")
    }

    @Test("A trailing `+` that isn't an offset stays part of the symbol")
    func plusWithoutOffset() {
        let trace = CrashModel.StackTrace(title: "1   Example   0x0000000100001234 operator + something", detail: "")

        #expect(trace.symbol == "operator + something")
    }

    @Test("A title without an address has no image and is its own symbol", arguments: ["frame", "", "main + 64"])
    func titleWithoutAddress(title: String) {
        let trace = CrashModel.StackTrace(title: title, detail: "")

        #expect(trace.image == nil)
        #expect(trace.symbol == title)
    }
}
