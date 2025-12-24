//
//  ConfigTextFieldView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigTextFieldView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var textValue: String = ""

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys
    let title: String
    let description: String?

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
        default:
            break
        }
    }

    private func loadGlobalCurrentValue() {
        guard let config = configVM.getConfiguration(for: .global, as: GlobalConfig.self) else { return }

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
        guard let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

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
        guard let config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        default:
            break
        }
    }

    private func loadPayPalCurrentValue() {
        guard let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

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
        guard let config = configVM.getConfiguration(for: .paypalVault, as: PayPalVaultConfig.self) else { return }

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
        guard let config = configVM.getConfiguration(for: .colesPay, as: ColesPayConfig.self) else { return }

        switch configKey {
        case .clientId:
            textValue = config.clientId
        default:
            break
        }
    }

    private func loadClickToPayCurrentValue() {
        guard let config = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            textValue = config.accessToken
        case .serviceId:
            textValue = config.serviceId
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
        default:
            break
        }
    }

    private func updateGlobalConfiguration(with value: String) {
        guard var config = configVM.getConfiguration(for: .global, as: GlobalConfig.self) else { return }

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
        guard var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: value,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                schemeSupport: config.schemeSupport
            )
        case .gatewayId:
            config = CardDetailsWidgetConfig(
                gatewayId: value.isEmpty ? nil : value,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                schemeSupport: config.schemeSupport
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .card, with: config)
    }

    private func updateGiftCardConfiguration(with value: String) {
        guard var config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .widgetAccessToken:
            config = GiftCardWidgetConfig(
                accessToken: value,
                storePin: config.storePin
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .giftCard, with: config)
    }

    private func updatePayPalConfiguration(with value: String) {
        guard var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

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
        guard var config = configVM.getConfiguration(for: .paypalVault, as: PayPalVaultConfig.self) else { return }

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
        guard var config = configVM.getConfiguration(for: .colesPay, as: ColesPayConfig.self) else { return }

        switch configKey {
        case .clientId:
            config = ColesPayConfig(clientId: value)
        default:
            return
        }
        configVM.updateConfiguration(for: .colesPay, with: config)
    }

    private func updateClickToPayConfiguration(with value: String) {
        guard var config = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) else { return }

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
}
