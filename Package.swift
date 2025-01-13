// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(iOS)
let package = Package(
    name: "Sentinel",
    platforms: [
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
            exclude: ["Classes/CustomLocation/CustomLocation.storyboard"],
            resources: [
                .process("Assets"),
                .copy("SupportingFiles/PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
#else
let package = Package(
    name: "Sentinel",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
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
            exclude: ["Classes/CustomLocation/CustomLocation.storyboard"],
            resources: [
                .process("Assets"),
                .copy("SupportingFiles/PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
#endif
