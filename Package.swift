// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Excluding some Tools due to being tightly coupled to some unsupported frameworks on macOS
#if os(macOS)
let excludedSources: [String] = [
    "Classes/CustomLocation",
    "Classes/EmailSender"
]
#else
let excludedSources: [String] = []
#endif

let package = Package(
    name: "Sentinel",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Sentinel",
            targets: ["Sentinel"]
        )
    ],
    targets: [
        .target(
            name: "Sentinel",
            dependencies: [],
            path: "Sentinel",
            exclude: excludedSources,
            resources: [
                .process("Assets"),
                .copy("SupportingFiles/PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
