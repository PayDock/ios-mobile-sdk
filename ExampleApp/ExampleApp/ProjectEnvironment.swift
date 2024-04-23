//
//  Environment.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

struct ProjectEnvironment {

    static let shared = ProjectEnvironment()

    enum Keys {
        static let secretKey = "SECRET_KEY"
        static let publicKey = "PUBLIC_KEY"
        static let applePayGatewayId = "APPLE_PAY_GATEWAY_ID"
        static let payPalGatewayId = "PAY_PAL_GATEWAY_ID"
        static let integrated3dsGatewayId = "INTEGRATED_3DS_GATEWAY_ID"
        static let standalone3dsGatewayId = "STANDALONE_3DS_GATEWAY_ID"
        static let flypayGatewayId = "FLYPAY_GATEWAY_ID"
        static let afterpayGatewayId = "AFTERPAY_GATEWAY_ID"
        static let mastercardServiceId = "MASTERCARD_SERVICE_ID"
    }

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError(".plist fire not found!")
        }
        return dict
    }()

    /// Main environment variable. Needs to be set externally to the correct value from the main app/extension target upon launch.
    /// Defaults to .sandbox if not set explicitly
    private(set) var environment: Environment = .sandbox

    enum Environment: String, CaseIterable {
        case production, sandbox, staging
    }

    func getEnvironmentEndpoint() -> String {
        switch environment {
        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
        case .staging: return "apista.paydock.com"
        }
    }

    func getSecretKey() -> String {
        guard let secretKey = Self.infoDictionary[Keys.secretKey] as? String else {
            fatalError("Secret key not found in .plist!")
        }
        return secretKey
    }

    func getPublicKey() -> String {
        guard let publicKey = Self.infoDictionary[Keys.publicKey] as? String else {
            fatalError("Public key not found in .plist!")
        }
        return publicKey
    }

    func getApplePayGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.applePayGatewayId] as? String else {
            print("Apple Pay gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getPayPalGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.payPalGatewayId] as? String else {
            print("PayPal gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getIntegrated3dsGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.integrated3dsGatewayId] as? String else {
            print("Integrated 3DS gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getStandalone3dsGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.standalone3dsGatewayId] as? String else {
            print("Standalone 3DS gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getFlyPayGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.flypayGatewayId] as? String else {
            print("FlyPay gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getAfterPayGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.afterpayGatewayId] as? String else {
            print("AfterPay gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

        func getMastercardServiceId() -> String? {
        guard let serviceId = Self.infoDictionary[Keys.mastercardServiceId] as? String else {
            print("Mastercard service ID not found in .plist!")
            return nil
        }
        return serviceId
    }
}
