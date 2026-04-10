// swift-tools-version: 5.7.1
import PackageDescription

let package = Package(
    name: "DataVault",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [.library(name: "DataVault", targets: ["DataVault"])],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataVault",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataVault"
        ),
        .testTarget(
            name: "DataVaultTests",
            dependencies: [
                "DataVault",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataVaultTests"
        )
    ]
)
