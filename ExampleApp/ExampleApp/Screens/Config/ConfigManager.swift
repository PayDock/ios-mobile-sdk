//
//  ConfigManager.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.12.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import SwiftUI

// Shared configuration manager
class ConfigManager: ObservableObject {

    static let shared = ConfigManager()

    // Configuration storage
    @Published var configurations: [ConfigWidgetsEnum: Any] = [:]

    private init() {
        setupDefaultConfigurations()
    }

    private func setupDefaultConfigurations() {
        setupGlobalConfiguration()
        setupCardConfiguration()
        setupAddressConfiguration()
        setupGiftCardConfiguration()
        setupPayPalConfigurations()
        setupAfterpayConfiguration()
        setupWalletConfigurations()
    }

    private func setupGlobalConfiguration() {
        configurations[.global] = GlobalConfig(
            apiAccessToken: ProjectEnvironment.shared.getApiAccessToken(),
            totalAmount: "10.00",
            currency: "AUD"
        )
    }

    private func setupCardConfiguration() {
        configurations[.card] = CardDetailsWidgetConfig(
            gatewayId: ProjectEnvironment.shared.getApplePayGatewayId(),
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            showCardTitle: true,
            collectCardholderName: true,
            allowSaveCard: SaveCardConfig(
                consentText: "Remember this card for next time.",
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: "Read our privacy policy",
                    privacyPolicyURL: "https://www.google.com"
                )
            ),
            schemeSupport: SupportedSchemesConfig(
                supportedSchemes: Set(CardScheme.allCases),
                enableValidation: true
            )
        )
    }

    private func setupAddressConfiguration() {
        configurations[.address] = AddressWidgetConfig(address: nil)
    }

    private func setupGiftCardConfiguration() {
        configurations[.giftCard] = GiftCardWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            storePin: false
        )
    }

    private func setupPayPalConfigurations() {
        configurations[.paypal] = PayPalWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
            requestShipping: true,
            fundingSource: .paypal
        )

        configurations[.paypalVault] = PayPalVaultConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
        )
    }

    private func setupAfterpayConfiguration() {
        configurations[.afterPay] = AfterpaySdkConfig(
            config: AfterpaySdkConfig.AfterpayConfiguration(
                minimumAmount: nil,
                maximumAmount: "1000",
                currency: "AUD",
                language: "en_AU",
                country: "AU"
            ),
            environment: .sandbox,
            options: AfterpaySdkConfig.CheckoutOptions(
                pickup: false,
                buyNow: false,
                shippingOptionRequired: false,
                enableSingleShippingOptionUpdate: false
            )
        )
    }

    private func setupWalletConfigurations() {
        configurations[.colesPay] = ColesPayConfig(
            clientId: ProjectEnvironment.shared.getColesPayClientId() ?? ""
        )

        configurations[.clickToPay] = ClickToPayWidgetConfig(
            serviceId: ProjectEnvironment.shared.getClickToPayServiceId() ?? "",
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            meta: nil
        )
    }

    func updateConfiguration<T>(for widget: ConfigWidgetsEnum, with config: T) {
        DispatchQueue.main.async {
            self.configurations[widget] = config
        }
    }

    func getConfiguration<T>(for widget: ConfigWidgetsEnum, as type: T.Type) -> T? {
        return configurations[widget] as? T
    }

    // Convenience methods for widgets
    func getCardDetailsConfig() -> CardDetailsWidgetConfig {
        return getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) ?? CardDetailsWidgetConfig(
            gatewayId: ProjectEnvironment.shared.getApplePayGatewayId(),
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            showCardTitle: true,
            collectCardholderName: true,
            allowSaveCard: SaveCardConfig(
                consentText: "Remember this card for next time.",
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: "Read our privacy policy",
                    privacyPolicyURL: "https://www.google.com"
                )
            ),
            schemeSupport: SupportedSchemesConfig(
                supportedSchemes: Set(CardScheme.allCases),
                enableValidation: true
            )
        )
    }

    func getGiftCardConfig() -> GiftCardWidgetConfig {
        return getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) ?? GiftCardWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            storePin: false
        )
    }

    func getPayPalConfig() -> PayPalWidgetConfig {
        return getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) ?? PayPalWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
            requestShipping: true,
            fundingSource: .paypal
        )
    }

    func getAddressConfig() -> AddressWidgetConfig {
        return getConfiguration(for: .address, as: AddressWidgetConfig.self) ?? AddressWidgetConfig(address: nil)
    }

    func getPayPalVaultConfig() -> PayPalVaultConfig {
        return getConfiguration(for: .paypalVault, as: PayPalVaultConfig.self) ?? PayPalVaultConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
        )
    }

    func getAfterpayConfig() -> AfterpaySdkConfig {
        return getConfiguration(for: .afterPay, as: AfterpaySdkConfig.self) ?? AfterpaySdkConfig(
            config: AfterpaySdkConfig.AfterpayConfiguration(
                minimumAmount: nil,
                maximumAmount: "1000",
                currency: "AUD",
                language: "en_AU",
                country: "AU"
            ),
            environment: {
                switch ProjectEnvironment.shared.environment {
                case .production: return .production
                case .sandbox, .staging: return .sandbox
                }
            }(),
            options: AfterpaySdkConfig.CheckoutOptions(
                pickup: false,
                buyNow: false,
                shippingOptionRequired: false,
                enableSingleShippingOptionUpdate: false
            )
        )
    }

    func getColesPayConfig() -> ColesPayConfig {
        return getConfiguration(for: .colesPay, as: ColesPayConfig.self) ?? ColesPayConfig(
            clientId: ProjectEnvironment.shared.getColesPayClientId() ?? ""
        )
    }

    func getClickToPayConfig() -> ClickToPayWidgetConfig {
        return getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) ?? ClickToPayWidgetConfig(
            serviceId: ProjectEnvironment.shared.getClickToPayServiceId() ?? "",
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            meta: nil
        )
    }

    func getGlobalConfig() -> GlobalConfig {
        return getConfiguration(for: .global, as: GlobalConfig.self) ?? GlobalConfig(
            apiAccessToken: ProjectEnvironment.shared.getApiAccessToken(),
            totalAmount: "10.00",
            currency: "AUD"
        )
    }
}
