// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let exclusions: [String] = [
    "Classes/CustomLocation",
    "Classes/EmailSender"
]
#else
let exclusions: [String] = []
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
            exclude: exclusions,
            resources: [
                .process("Assets"),
                .copy("SupportingFiles/PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
