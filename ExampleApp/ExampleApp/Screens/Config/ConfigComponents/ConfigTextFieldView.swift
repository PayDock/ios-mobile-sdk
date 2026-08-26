//
//  ConfigTextFieldView.swift
//  ExampleApp

import SwiftUI
import MobileSDK

struct ConfigTextFieldView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var textValue: String = ""

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys?
    let title: String
    let description: String?

    init(selectedWidget: ConfigWidgetsEnum,
         configKey: ConfigKeys? = nil,
         title: String,
         description: String? = nil) {
        self.selectedWidget = selectedWidget
        self.configKey = configKey
        self.title = title
        self.description = description
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let description = description {
                        Text(description).font(.caption)
                            .padding(16.0)
                    }
                    DimensionsFieldView(title: title, text: $textValue)
                        .padding(.top, description != nil ? 0.0 : 16.0)
                }
                .padding(.bottom, 16.0)
                .navigationTitle(title)
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .onAppear {
            loadCurrentValue()
        }
        .onChange(of: textValue) { _ in
            updateConfiguration(with: textValue)
        }
    }

    private func loadCurrentValue() {
        switch selectedWidget {
        case .global:
            loadGlobalCurrentValue()
        case .card:
            loadCardCurrentValue()
        case .giftCard:
            loadGiftCardCurrentValue()
        case .paypal:
            loadPayPalCurrentValue()
        case .paypalVault:
            loadPayPalVaultCurrentValue()
        case .colesPay:
            loadColesPayCurrentValue()
        case .clickToPay:
            loadClickToPayCurrentValue()
        case .zip:
            loadZipCurrentValue()
        default:
            break
        }
    }

    private func loadGlobalCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .global, as: GlobalConfig.self) else { return }

        switch configKey {
        case .apiAccessToken:
            textValue = config.apiAccessToken
        case .totalAmount:
            textValue = config.totalAmount
        case .currency:
            textValue = config.currency
        default:
            break
        }
    }

    private func loadCardCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .gatewayId:
            textValue = config.gatewayId ?? ""
        default:
            break
        }
    }

    private func loadGiftCardCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        default:
            break
        }
    }

    private func loadPayPalCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .gatewayId:
            textValue = config.gatewayId
        default:
            break
        }
    }

    private func loadPayPalVaultCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .paypalVault, as: PayPalVaultConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .gatewayId:
            textValue = config.gatewayId
        default:
            break
        }
    }

    private func loadColesPayCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .colesPay, as: ColesPayConfig.self) else { return }

        switch configKey {
        case .clientId:
            textValue = config.clientId
        default:
            break
        }
    }

    private func loadClickToPayCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .serviceId:
            textValue = config.serviceId
        default:
            break
        }
    }

    private func loadZipCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .gatewayId:
            textValue = config.gatewayId
        case .firstName:
            textValue = config.firstName ?? ""
        case .lastName:
            textValue = config.lastName ?? ""
        case .email:
            textValue = config.email ?? ""
        case .phoneNumber:
            textValue = config.phone ?? ""
        case .dateOfBirth:
            textValue = config.dateOfBirth ?? ""
        default:
            break
        }
    }

    private func updateConfiguration(with value: String) {
        switch selectedWidget {
        case .global:
            updateGlobalConfiguration(with: value)
        case .card:
            updateCardConfiguration(with: value)
        case .giftCard:
            updateGiftCardConfiguration(with: value)
        case .paypal:
            updatePayPalConfiguration(with: value)
        case .paypalVault:
            updatePayPalVaultConfiguration(with: value)
        case .colesPay:
            updateColesPayConfiguration(with: value)
        case .clickToPay:
            updateClickToPayConfiguration(with: value)
        case .zip:
            updateZipConfiguration(with: value)
        default:
            break
        }
    }

    private func updateGlobalConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .global, as: GlobalConfig.self) else { return }

        switch configKey {
        case .apiAccessToken:
            config = GlobalConfig(
                apiAccessToken: value,
                totalAmount: config.totalAmount,
                currency: config.currency
            )
        case .totalAmount:
            config = GlobalConfig(
                apiAccessToken: config.apiAccessToken,
                totalAmount: value,
                currency: config.currency
            )
        case .currency:
            config = GlobalConfig(
                apiAccessToken: config.apiAccessToken,
                totalAmount: config.totalAmount,
                currency: value
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .global, with: config)
    }

    private func updateCardConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: value,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton
            )
        case .gatewayId:
            config = CardDetailsWidgetConfig(
                gatewayId: value.isEmpty ? nil : value,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .card, with: config)
    }

    private func updateGiftCardConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = GiftCardWidgetConfig(
                accessToken: value,
                storePin: config.storePin,
                activePrimaryButton: config.activePrimaryButton
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .giftCard, with: config)
    }

    private func updatePayPalConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = PayPalWidgetConfig(
                accessToken: value,
                gatewayId: config.gatewayId,
                requestShipping: config.requestShipping,
                fundingSource: config.fundingSource
            )
        case .gatewayId:
            config = PayPalWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: value,
                requestShipping: config.requestShipping,
                fundingSource: config.fundingSource
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .paypal, with: config)
    }

    private func updatePayPalVaultConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .paypalVault, as: PayPalVaultConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = PayPalVaultConfig(
                accessToken: value,
                gatewayId: config.gatewayId
            )
        case .gatewayId:
            config = PayPalVaultConfig(
                accessToken: config.accessToken,
                gatewayId: value
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .paypalVault, with: config)
    }

    private func updateColesPayConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .colesPay, as: ColesPayConfig.self) else { return }

        switch configKey {
        case .clientId:
            config = ColesPayConfig(clientId: value)
        default:
            return
        }
        configVM.updateConfiguration(for: .colesPay, with: config)
    }

    private func updateClickToPayConfiguration(with value: String) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = ClickToPayWidgetConfig(
                serviceId: config.serviceId,
                accessToken: value,
                meta: config.meta
            )
        case .serviceId:
            config = ClickToPayWidgetConfig(
                serviceId: value,
                accessToken: config.accessToken,
                meta: config.meta
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .clickToPay, with: config)
    }

    // swiftlint:disable:next function_body_length
    private func updateZipConfiguration(with value: String) {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return }

        let updatedConfig: ZipWidgetConfig

        switch configKey {
        case .widgetAccessToken:
            updatedConfig = ZipWidgetConfig(
                accessToken: value,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .gatewayId:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: value,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .firstName:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: value,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .lastName:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: value,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .email:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: value,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .phoneNumber:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: value.isEmpty ? nil : value,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .dateOfBirth:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: value.isEmpty ? nil : value,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .zip, with: updatedConfig)
    }
}
