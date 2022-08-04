// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sentinel",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "Sentinel",
            targets: ["Sentinel"]
        ),
        .library(
            name: "SentinelLoggie",
            targets: ["SentinelLoggie"]
        ),
        .library(
            name: "SentinelCollar",
            targets: ["SentinelCollar"]
        )
    ],
    dependencies: [
        .package(name: "Loggie", url: "https://github.com/infinum/iOS-Loggie.git", .upToNextMajor(from: "2.3.3")),
        .package(name: "Collar", url: "https://github.com/infinum/ios-collar.git", .upToNextMajor(from: "1.0.3"))
    ],
    targets: [
        .target(
            name: "Sentinel",
            dependencies: [],
            path: "Sentinel",
            exclude: [
                "Classes/Loggie/LoggieTool.swift",
                "Classes/Collar/CollarTool.swift"
            ],
            resources: [
                .process("Assets")
            ]
        ),
        .target(
            name: "SentinelLoggie",
            dependencies: ["Sentinel", "Loggie"],
            path: "Sentinel/Classes/Loggie"
        ),
        .target(
            name: "SentinelCollar",
            dependencies: ["Sentinel", "Collar"],
            path: "Sentinel/Classes/Collar"
        )
    ]
)
