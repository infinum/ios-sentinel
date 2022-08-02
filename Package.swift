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
            targets: ["Sentinel"])
    ],
    dependencies: [
        .package(name: "Loggie", url: "https://github.com/infinum/iOS-Loggie.git", .upToNextMajor(from: "2.3.2")),
        .package(name: "Collar", url: "https://github.com/infinum/ios-collar.git", .upToNextMajor(from: "1.0.2"))
    ],
    targets: [
        .target(
            name: "Sentinel",
            dependencies: ["Loggie", "Collar"],
            path: "Sentinel/Classes"
        )
    ]
)
