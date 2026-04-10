// swift-tools-version: 5.7.1
import PackageDescription

let package = Package(
    name: "DataPaymentSources",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [.library(name: "DataPaymentSources", targets: ["DataPaymentSources"])],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataPaymentSources",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataPaymentSources"
        ),
        .testTarget(
            name: "DataPaymentSourcesTests",
            dependencies: [
                "DataPaymentSources",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataPaymentSourcesTests"
        )
    ]
)
