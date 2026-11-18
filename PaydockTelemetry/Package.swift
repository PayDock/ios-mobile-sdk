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
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.5.0")
    ],
    targets: [
        .target(
            name: "PaydockTelemetry",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "Sources/PaydockTelemetry",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "PaydockTelemetryTests",
            dependencies: ["PaydockTelemetry"],
            path: "Tests/PaydockTelemetryTests",
            resources: [.copy("Fixtures")]
        )
    ]
)
