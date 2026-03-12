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
        static let apiAccessToken = "ACCESS_TOKEN_API"
        static let widgetAccessToken = "ACCESS_TOKEN_WIDGET"
        static let applePayGatewayId = "SERVICE_ID_APPLE_PAY_MPGS"
        static let payPalGatewayId = "SERVICE_ID_PAYPAL"
        static let mpgsGatewayId = "SERVICE_ID_MPGS"
        static let mpgsTestGatewayId = "SERVICE_ID_MPGS_TEST"
        static let gpaymentsServiceId = "SERVICE_ID_GPAYMENTS"
        static let colesPayGatewayId = "SERVICE_ID_COLES_PAY"
        static let afterpayGatewayId = "SERVICE_ID_AFTERPAY"
        static let clickToPayServiceId = "SERVICE_ID_CLICK_TO_PAY"
        static let colesPayClientId = "WALLET_ID_COLES_PAY"
        static let applePayMerchantId = "MERCHANT_ID_APPLE_PAY"
        static let zipGatewayId = "SERVICE_ID_ZIP"
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
        case .staging: return "apista.paydock.com"
        }
    }

    func getApiAccessToken() -> String {
        guard let accessToken = Self.infoDictionary[Keys.apiAccessToken] as? String else {
            fatalError("API access token not found in .plist!")
        }
        return accessToken
    }

    func getWidgetAccessToken() -> String {
        guard let accessToken = Self.infoDictionary[Keys.widgetAccessToken] as? String else {
            fatalError("Widget access token not found in .plist!")
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

    func getMPGSGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.mpgsGatewayId] as? String else {
            print("MPGS gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getMPGSTestGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.mpgsTestGatewayId] as? String else {
            print("MPGS test gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getGPaymentsServiceId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.gpaymentsServiceId] as? String else {
            print("Standalone 3DS gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getColesPayGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.colesPayGatewayId] as? String else {
            print("Coles Pay gateway ID not found in .plist!")
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

    func getClickToPayServiceId() -> String? {
        guard let serviceId = Self.infoDictionary[Keys.clickToPayServiceId] as? String else {
            print("Mastercard service ID not found in .plist!")
            return nil
        }
        return serviceId
    }

    func getColesPayClientId() -> String? {
        guard let clientId = Self.infoDictionary[Keys.colesPayClientId] as? String else {
            print("Coles Pay client ID not found in .plist!")
            return nil
        }
        return clientId
    }

    func getZipGatewayId() -> String? {
        guard let gatewayId = Self.infoDictionary[Keys.zipGatewayId] as? String else {
            print("Zip gateway ID not found in .plist!")
            return nil
        }
        return gatewayId
    }

    func getApplePayMerchantId() -> String? {
        guard let merchantId = Self.infoDictionary[Keys.applePayMerchantId] as? String else {
            print("Apple Pay merchant ID not found in .plist!")
            return nil
        }
        return merchantId
    }
}
