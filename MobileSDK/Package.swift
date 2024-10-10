// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MobileSDK",
            targets: ["MobileSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/afterpay/sdk-ios", exact: "5.4.0"),
        .package(url: "https://gitlab.com/paydock/bounded-contexts/mobile/mobile-lib-networking-ios", branch: "feature/mock-api-client")
        // TODO: - Replace once development is finished
//        .package(url: "https://github.com/PayDock/ios-core-networking", exact: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MobileSDK",
            dependencies: [
                .product(name: "Afterpay", package: "sdk-ios"),
                // TODO: - Replace once development is finished
//                .product(name: "NetworkingLib", package: "ios-core-networking")],
                .product(name: "NetworkingLib", package: "mobile-lib-networking-ios")],
            path: "Sources",
            resources: [
                .copy("MobileSDK/Resources/JSON/paypal_vault_session_auth_success_response.json"),
                .copy("MobileSDK/Resources/JSON/paypal_vault_setup_token_success_response.json"),
                .copy("MobileSDK/Resources/JSON/paypal_vault_get_client_id_success_response.json"),
            ]
        ),
        .testTarget(
            name: "MobileSDKTests",
            dependencies: ["MobileSDK"],
            path: "Tests",
            resources: [
                .copy("MobileSDKTests/Resources/JSON/card_tokenisation_error_response.json"),
                .copy("MobileSDKTests/Resources/JSON/card_tokenisation_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_session_auth_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_session_auth_error_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_setup_token_success_response.json"),
                .copy("MobileSDKTests/Resources/JSON/paypal_vault_get_client_id_success_response.json")
            ]
        ),
    ]
)
