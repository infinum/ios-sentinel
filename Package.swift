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
        )
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
        )
    ]
)
