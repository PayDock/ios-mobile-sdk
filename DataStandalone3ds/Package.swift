// swift-tools-version: 5.7.1
import PackageDescription

let package = Package(
    name: "DataStandalone3ds",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [.library(name: "DataStandalone3ds", targets: ["DataStandalone3ds"])],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataStandalone3ds",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataStandalone3ds"
        ),
        .testTarget(
            name: "DataStandalone3dsTests",
            dependencies: [
                "DataStandalone3ds",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataStandalone3dsTests"
        )
    ]
)
