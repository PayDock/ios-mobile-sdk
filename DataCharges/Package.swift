// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataCharges",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DataCharges",
            targets: ["DataCharges"])
    ],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataCharges",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataCharges"
        ),
        .testTarget(
            name: "DataChargesTests",
            dependencies: [
                "DataCharges",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataChargesTests"
        )
    ]
)
