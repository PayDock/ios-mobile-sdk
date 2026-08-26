// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MobileSDK",
            targets: ["MobileSDK"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/afterpay/sdk-ios", exact: "5.9.0"),
        .package(url: "https://github.com/paypal/paypal-ios/", exact: "2.0.1"),
        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.3.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.59.1")
    ],
    targets: [
        // Internal shared models
        .target(
            name: "CommonModels",
            path: "CommonModels/Sources/CommonModels"
        ),
        .testTarget(
            name: "CommonModelsTests",
            dependencies: ["CommonModels"],
            path: "CommonModels/Tests/CommonModelsTests"
        ),

        // Data layer targets
        .target(
            name: "DataGateways",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataGateways/Sources/DataGateways"
        ),
        .testTarget(
            name: "DataGatewaysTests",
            dependencies: [
                "DataGateways",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataGateways/Tests/DataGatewaysTests"
        ),

        .target(
            name: "DataPaymentSources",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataPaymentSources/Sources/DataPaymentSources"
        ),
        .testTarget(
            name: "DataPaymentSourcesTests",
            dependencies: [
                "DataPaymentSources",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataPaymentSources/Tests/DataPaymentSourcesTests"
        ),

        .target(
            name: "DataCharges",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataCharges/Sources/DataCharges"
        ),
        .testTarget(
            name: "DataChargesTests",
            dependencies: [
                "DataCharges",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataCharges/Tests/DataChargesTests"
        ),

        .target(
            name: "DataCustomer",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataCustomer/Sources/DataCustomer"
        ),
        .testTarget(
            name: "DataCustomerTests",
            dependencies: [
                "DataCustomer",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataCustomer/Tests/DataCustomerTests"
        ),

        .target(
            name: "DataVault",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataVault/Sources/DataVault"
        ),
        .testTarget(
            name: "DataVaultTests",
            dependencies: [
                "DataVault",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataVault/Tests/DataVaultTests"
        ),

        .target(
            name: "DataMPGS3ds",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataMPGS3ds/Sources/DataMPGS3ds"
        ),
        .testTarget(
            name: "DataMPGS3dsTests",
            dependencies: [
                "DataMPGS3ds",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataMPGS3ds/Tests/DataMPGS3dsTests"
        ),

        .target(
            name: "DataStandalone3ds",
            dependencies: [
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataStandalone3ds/Sources/DataStandalone3ds"
        ),
        .testTarget(
            name: "DataStandalone3dsTests",
            dependencies: [
                "DataStandalone3ds",
                "CommonModels",
                .product(name: "NetworkingLib", package: "ios-core-networking")
            ],
            path: "DataStandalone3ds/Tests/DataStandalone3dsTests"
        ),

        .target(
            name: "BinProcessing",
            dependencies: [],
            path: "BinProcessing/Sources/BinProcessing",
            resources: [
                .copy("Resources/JSON/card-schemes.json")
            ]
        ),
        .testTarget(
            name: "BinProcessingTests",
            dependencies: ["BinProcessing"],
            path: "BinProcessing/Tests/BinProcessingTests"
        ),

        // Main SDK target
        .target(
            name: "MobileSDK",
            dependencies: [
                "CommonModels",
                "DataGateways",
                "DataPaymentSources",
                "DataCharges",
                "DataCustomer",
                "DataVault",
                "DataMPGS3ds",
                "DataStandalone3ds",
                "BinProcessing",
                .product(name: "Afterpay", package: "sdk-ios"),
                .product(name: "NetworkingLib", package: "ios-core-networking"),
                .product(name: "FraudProtection", package: "paypal-ios"),
                .product(name: "PaymentButtons", package: "paypal-ios"),
                .product(name: "PayPalWebPayments", package: "paypal-ios")
            ],
            path: "Sources",
            resources: [
                .copy("MobileSDK/Resources/JSON/paypal_vault_session_auth_success_response.json"),
                .copy("MobileSDK/Resources/JSON/paypal_vault_setup_token_success_response.json"),
                .copy("MobileSDK/Resources/JSON/paypal_vault_get_client_id_success_response.json"),
                .copy("MobileSDK/Resources/JSON/paypal_vault_payment_token_success_response.json")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "MobileSDKTests",
            dependencies: [
                "MobileSDK",
                "BinProcessing"
            ],
            path: "Tests",
            resources: [
                .copy("MobileSDKTests/Resources/JSON/card_tokenisation_error_response.json"),
                .copy("MobileSDKTests/Resources/JSON/card_tokenisation_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_session_auth_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_session_auth_error_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_setup_token_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_get_client_id_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_payment_token_success_response.json")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        )
    ]
)
