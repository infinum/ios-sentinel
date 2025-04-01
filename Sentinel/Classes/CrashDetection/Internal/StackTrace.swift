//
//  StackTrace.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

// Inspiration link: https://github.com/DebugSwift/DebugSwift

import Foundation
import MachO

enum StackTrace {

    static func classNameFromSymbol(_ symbol: String) -> String? {
        try? fetchClassName(for: symbol, pattern: "\\$s(\\S+)\\d+")
    }

    static func fileInfoFromSymbol(_ symbol: String) -> (file: String, line: Int, function: String)? {
        let pattern = "\\s+(\\S+\\.swift):(\\d+)\\s+(\\S+\\()"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: symbol.utf16.count)

            if let match = regex.firstMatch(in: symbol, options: [], range: range) {
                let fileRange = Range(match.range(at: 1), in: symbol)
                let lineRange = Range(match.range(at: 2), in: symbol)
                let functionRange = Range(match.range(at: 3), in: symbol)

                if let file = fileRange.flatMap({ String(symbol[$0]) }),
                   let lineString = lineRange.flatMap({ String(symbol[$0].utf8) }),
                   let line = Int(lineString),
                   let function = functionRange.flatMap({ String(symbol[$0].utf16) }) {
                    return (file, line, function)
                }
            }
        } catch { }

        return nil
    }

    static func binaryInformation() -> String {
        var binaryInfo = ""

        for imageIndex in 0..<_dyld_image_count() {
            if let imageNamePtr = _dyld_get_image_name(imageIndex) {
                let imageName = String(cString: imageNamePtr)
                let slideAddress = slideAddressForImageIndex(imageIndex)
                binaryInfo += "\(String(format: "0x%0x", slideAddress)) - \(imageName):\n"
            }
        }

        return binaryInfo
    }

    static func slideAddressForImageIndex(_ index: UInt32) -> Int64 {
        return Int64(_dyld_get_image_vmaddr_slide(index))
    }
}

private extension StackTrace {

    @available(iOS, deprecated: 16, message: "Use Regex instead")
    static func fetchClassName(for symbol: String, pattern: String) throws -> String? {
        let range = NSRange(location: 0, length: symbol.count)
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        guard let match = regex.firstMatch(in: symbol, options: [], range: range) else {
            return nil
        }

        let classNameRange = Range(match.range(at: 1), in: symbol)
        guard let className = classNameRange.flatMap({ String(symbol[$0]) }) else {
            return nil
        }
        return className
    }
}

