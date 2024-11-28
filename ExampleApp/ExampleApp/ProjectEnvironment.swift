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
        static let configuration = "CONFIGURATION"
        static let secretKey = "SECRET_KEY"
        static let accessToken = "ACCESS_TOKEN"
        static let applePayGatewayId = "APPLE_PAY_GATEWAY_ID"
        static let payPalGatewayId = "PAY_PAL_GATEWAY_ID"
        static let integrated3dsGatewayId = "INTEGRATED_3DS_GATEWAY_ID"
        static let standalone3dsGatewayId = "STANDALONE_3DS_GATEWAY_ID"
        static let flypayGatewayId = "FLYPAY_GATEWAY_ID"
        static let afterpayGatewayId = "AFTERPAY_GATEWAY_ID"
        static let mastercardServiceId = "MASTERCARD_SERVICE_ID"
        static let flypayClientId = "FLYPAY_CLIENT_ID"
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

    init() {
        guard let currentConfiguration = Self.infoDictionary[Keys.configuration] as? String else {
            fatalError("Configuration key not found in .plist!")
        }

        if currentConfiguration == "Debug (Production)" || currentConfiguration == "Release (Production)" {
            self.environment = .production
        } else if currentConfiguration == "Debug (Sandbox)" || currentConfiguration == "Release (Sandbox)" {
            self.environment = .sandbox
        } else if currentConfiguration == "Debug (Staging)" || currentConfiguration == "Release (Staging)" {
            self.environment = .staging
        }
    }

    func getEnvironmentEndpoint() -> String {
        switch environment {
        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
        case .staging: return "apista-10.paydock.com"
        }
    }

    func getSecretKey() -> String {
        guard let secretKey = Self.infoDictionary[Keys.secretKey] as? String else {
            fatalError("Secret key not found in .plist!")
        }
        return secretKey
    }

    func getAccessToken() -> String {
        if let accessToken = Self.accessToken {
            return accessToken
        }
        guard let accessToken = Self.infoDictionary[Keys.accessToken] as? String else {
            fatalError("Access token not found in .plist!")
        }
        return accessToken
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

    func getAfterpayGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.afterpayGatewayId] as? String else {
            print("Afterpay gateway ID not found in .plist!")
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
    
    func getFlyPayClientId() -> String? {
        guard let clientId = Self.infoDictionary[Keys.flypayClientId] as? String else {
            print("FlyPay client ID not found in .plist!")
            return nil
        }
        return clientId
    }

    static var accessToken: String? = nil
}
