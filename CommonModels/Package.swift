// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonModels",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CommonModels",
            targets: ["CommonModels"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CommonModels",
            dependencies: [],
            path: "Sources/CommonModels"
        ),
        .testTarget(
            name: "CommonModelsTests",
            dependencies: ["CommonModels"],
            path: "Tests/CommonModelsTests"
        )
    ]
)
