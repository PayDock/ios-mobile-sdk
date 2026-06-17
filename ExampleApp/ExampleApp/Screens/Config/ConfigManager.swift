//
//  ConfigManager.swift
//  ExampleApp
//
//  Copyright © 2025 Paydock Ltd. All rights reserved.

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
        setupApplePayConfiguration()
        setupColesPayConfiguration()
        setupClickToPayConfiguration()
        setupZipConfiguration()
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
            gatewayId: ProjectEnvironment.shared.getMPGSGatewayId(),
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            collectCardholderName: true,
            allowSaveCard: SaveCardConfig(
                consentText: "Remember this card for next time.",
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: "Read our privacy policy",
                    privacyPolicyURL: "https://www.google.com"
                )
            ),
            storeSecurityCode: nil,
            schemeSupport: SupportedSchemesConfig(
                supportedSchemes: Set(CardScheme.allCases),
                enableValidation: true
            ),
            activePrimaryButton: true
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

    private func setupColesPayConfiguration() {
        configurations[.colesPay] = ColesPayConfig(
            clientId: ProjectEnvironment.shared.getColesPayClientId() ?? ""
        )
    }

    private func setupClickToPayConfiguration() {
        configurations[.clickToPay] = ClickToPayWidgetConfig(
            serviceId: ProjectEnvironment.shared.getClickToPayServiceId() ?? "",
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            meta: nil
        )
    }

    private func setupApplePayConfiguration() {
        configurations[.applePay] = ApplePayConfigParams(
            serviceId: ProjectEnvironment.shared.getApplePayServiceId() ?? "",
            amountLabel: "Amount",
            countryCode: "AU",
            merchantIdentifier: ProjectEnvironment.shared.getApplePayMerchantId() ?? "",
            requireBillingAddress: false,
            requireShippingAddress: false,
            showSetupButtonIfRequired: false,
            performAvailabilityChecks: true
        )
    }

    // swiftlint:disable:next function_body_length
    private func setupZipConfiguration() {
        let globalConfig = getGlobalConfig()
        let amount = Decimal(string: globalConfig.totalAmount) ?? 10.00
        let currency = globalConfig.currency

        configurations[.zip] = ZipWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getZipGatewayId() ?? "",
            amount: amount,
            currency: currency,
            firstName: "Joshua",
            lastName: "Wood",
            email: "joshuawood@hotmail.com.au",
            phone: "+61412345678",
            tokenize: true,
            gender: "male",
            dateOfBirth: nil,
            shippingType: nil,
            billing: ZipWidgetConfig.Address(
                firstName: "Joshua",
                lastName: "Wood",
                line1: "Suite 660",
                line2: "test",
                city: "Sydney",
                state: "LA",
                postcode: "3223",
                country: "AU"
            ),
            shipping: ZipWidgetConfig.Address(
                firstName: "Joshua",
                lastName: "Wood",
                line1: "Suite 660",
                line2: "822 Ruiz Square",
                city: "Sydney",
                state: "LA",
                postcode: "3223",
                country: "AU"
            ),
            items: [
                ZipWidgetConfig.Item(
                    name: "ACME Toolbox",
                    amount: "2.00",
                    quantity: 1,
                    reference: "Fuga consequuntur sint ab magnam"
                ),
                ZipWidgetConfig.Item(
                    name: "Device 42",
                    amount: "2.00",
                    quantity: 1,
                    reference: "Fuga consequuntur sint ab magnam"
                )
            ],
            statistics: nil
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
            gatewayId: ProjectEnvironment.shared.getMPGSGatewayId(),
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            collectCardholderName: true,
            allowSaveCard: SaveCardConfig(
                consentText: "Remember this card for next time.",
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: "Read our privacy policy",
                    privacyPolicyURL: "https://www.google.com"
                )
            ),
            storeSecurityCode: nil,
            schemeSupport: SupportedSchemesConfig(
                supportedSchemes: Set(CardScheme.allCases),
                enableValidation: true
            ),
            activePrimaryButton: true
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

    func getApplePayConfigParams() -> ApplePayConfigParams {
        return getConfiguration(for: .applePay, as: ApplePayConfigParams.self) ?? ApplePayConfigParams(
            serviceId: ProjectEnvironment.shared.getApplePayServiceId() ?? "",
            amountLabel: "Amount",
            countryCode: "AU",
            merchantIdentifier: ProjectEnvironment.shared.getApplePayMerchantId() ?? "",
            requireBillingAddress: false,
            requireShippingAddress: false,
            showSetupButtonIfRequired: false,
            performAvailabilityChecks: true
        )
    }

    func getApplePayWidgetConfig() -> ApplePayWidgetConfig {
        let params = getApplePayConfigParams()
        let globalConfig = getGlobalConfig()

        let pkPaymentRequest = MobileSDK.createApplePayRequest(
            amount: Decimal(string: globalConfig.totalAmount) ?? 0,
            amountLabel: params.amountLabel,
            countryCode: params.countryCode,
            currencyCode: globalConfig.currency,
            merchantIdentifier: params.merchantIdentifier,
            requireBillingAddress: params.requireBillingAddress,
            requireShippingAddress: params.requireShippingAddress
        )

        return ApplePayWidgetConfig(
            serviceId: params.serviceId,
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            pkPaymentRequest: pkPaymentRequest,
            showSetUpButtonWhenNoCardsEnrolled: params.showSetupButtonIfRequired,
            performAvailabilityChecks: params.performAvailabilityChecks
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

    func getZipConfig() -> ZipWidgetConfig {
        let globalConfig = getGlobalConfig()
        let amount = Decimal(string: globalConfig.totalAmount) ?? 10.00
        let currency = globalConfig.currency

        let config = getConfiguration(for: .zip, as: ZipWidgetConfig.self)
        return ZipWidgetConfig(
            accessToken: config?.accessToken ?? ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: config?.gatewayId ?? ProjectEnvironment.shared.getZipGatewayId() ?? "",
            amount: amount,
            currency: currency,
            firstName: config?.firstName,
            lastName: config?.lastName,
            email: config?.email,
            phone: config?.phone,
            tokenize: config?.tokenize,
            gender: config?.gender,
            dateOfBirth: config?.dateOfBirth,
            shippingType: config?.shippingType,
            billing: config?.billing,
            shipping: config?.shipping,
            items: config?.items,
            statistics: nil
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
