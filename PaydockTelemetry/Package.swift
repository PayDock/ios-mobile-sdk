// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaydockTelemetry",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PaydockTelemetry",
            targets: ["PaydockTelemetry"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PaydockTelemetry",
            dependencies: [],
            path: "Sources/PaydockTelemetry"
        ),
        .testTarget(
            name: "PaydockTelemetryTests",
            dependencies: ["PaydockTelemetry"],
            path: "Tests/PaydockTelemetryTests"
        )
    ]
)
