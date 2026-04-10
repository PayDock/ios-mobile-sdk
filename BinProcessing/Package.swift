// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BinProcessing",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BinProcessing",
            targets: ["BinProcessing"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BinProcessing",
            dependencies: [],
            path: "Sources/BinProcessing",
            resources: [
                .copy("Resources/JSON/card-schemes.json")
            ]
        ),
        .testTarget(
            name: "BinProcessingTests",
            dependencies: ["BinProcessing"],
            path: "Tests/BinProcessingTests"
        )
    ]
)
