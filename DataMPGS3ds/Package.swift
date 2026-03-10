// swift-tools-version: 5.7.1
import PackageDescription

let package = Package(
    name: "DataMPGS3ds",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [.library(name: "DataMPGS3ds", targets: ["DataMPGS3ds"])],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataMPGS3ds",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataMPGS3ds"
        ),
        .testTarget(
            name: "DataMPGS3dsTests",
            dependencies: [
                "DataMPGS3ds",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataMPGS3dsTests"
        )
    ]
)
