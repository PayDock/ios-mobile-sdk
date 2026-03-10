// swift-tools-version: 5.7.1
import PackageDescription

let package = Package(
    name: "DataCustomer",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [.library(name: "DataCustomer", targets: ["DataCustomer"])],
    dependencies: [
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.2.2"),
        .package(path: "../CommonModels")
    ],
    targets: [
        .target(
            name: "DataCustomer",
            dependencies: [
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Sources/DataCustomer"
        ),
        .testTarget(
            name: "DataCustomerTests",
            dependencies: [
                "DataCustomer",
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "CommonModels", package: "CommonModels")
            ],
            path: "Tests/DataCustomerTests"
        )
    ]
)
