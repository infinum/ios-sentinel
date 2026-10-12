// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sentinel",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Sentinel",
            targets: ["Sentinel"]
        ),
        .library(
            name: "SentinelPulse",
            targets: ["SentinelPulse"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Pulse.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Sentinel",
            dependencies: [],
            path: "Sentinel",
            resources: [
                .process("Assets"),
                .copy("SupportingFiles/PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "SentinelPulse",
            dependencies: [
                "Sentinel",
                // Pulse has no embeddable console on macOS, so the tool is iOS-only.
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS])),
                .product(name: "PulseUI", package: "Pulse", condition: .when(platforms: [.iOS]))
            ],
            path: "SentinelPulse"
        ),
        .testTarget(
            name: "SentinelTests",
            dependencies: ["Sentinel"],
            path: "Tests/SentinelTests"
        ),
        .testTarget(
            name: "SentinelPulseTests",
            dependencies: ["SentinelPulse"],
            path: "Tests/SentinelPulseTests"
        )
    ]
)
