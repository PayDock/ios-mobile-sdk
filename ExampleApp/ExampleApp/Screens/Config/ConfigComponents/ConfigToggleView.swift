//
//  ConfigToggleView.swift
//  ExampleApp

import SwiftUI
import MobileSDK

struct ConfigToggleView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var toggleValue: Bool = false

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys?
    let title: String

    init(selectedWidget: ConfigWidgetsEnum,
         configKey: ConfigKeys? = nil,
         title: String) {
        self.selectedWidget = selectedWidget
        self.configKey = configKey
        self.title = title
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitleView(title: "Setting")

                    VStack(alignment: .leading, spacing: 8) {
                        ToggleFieldView(title: title, isOn: $toggleValue, onChange: {
                            updateConfiguration(with: toggleValue)
                        })
                    }

                    ResetStyleButton {
                        resetToDefault()
                    }
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
        let value: Bool?
        switch selectedWidget {
        case .card: value = loadCardValue()
        case .giftCard: value = loadGiftCardValue()
        case .address: value = loadAddressValue()
        case .paypal: value = loadPayPalValue()
        case .zip: value = loadZipValue()
        default: value = nil
        }
        if let value {
            toggleValue = value
        }
    }

    private func loadCardValue() -> Bool? {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return nil }
        switch configKey {
        case .collectCardholderName: return config.collectCardholderName
        case .activePrimaryButton: return config.activePrimaryButton
        case .showSubmitButton: return config.showSubmitButton
        default: return nil
        }
    }

    private func loadGiftCardValue() -> Bool? {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return nil }
        switch configKey {
        case .storePin: return config.storePin
        case .activePrimaryButton: return config.activePrimaryButton
        case .showSubmitButton: return config.showSubmitButton
        default: return nil
        }
    }

    private func loadAddressValue() -> Bool? {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .address, as: AddressWidgetConfig.self) else { return nil }
        switch configKey {
        case .activePrimaryButton: return config.activePrimaryButton
        default: return nil
        }
    }

    private func loadPayPalValue() -> Bool? {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return nil }
        switch configKey {
        case .requestShipping: return config.requestShipping
        default: return nil
        }
    }

    private func loadZipValue() -> Bool? {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return nil }
        switch configKey {
        case .tokenize: return config.tokenize ?? true
        default: return nil
        }
    }

    private func updateConfiguration(with value: Bool) {
        switch selectedWidget {
        case .card:
            updateCardConfiguration(with: value)
        case .giftCard:
            updateGiftCardConfiguration(with: value)
        case .address:
            updateAddressConfiguration(with: value)
        case .paypal:
            updatePayPalConfiguration(with: value)
        case .zip:
            updateZipConfiguration(with: value)
        default:
            break
        }
    }

    private func updateCardConfiguration(with value: Bool) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

        switch configKey {
        case .collectCardholderName:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: value,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton,
                showSubmitButton: config.showSubmitButton
            )
        case .activePrimaryButton:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: value,
                showSubmitButton: config.showSubmitButton
            )
        case .showSubmitButton:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton,
                showSubmitButton: value
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .card, with: config)
    }

    private func updateGiftCardConfiguration(with value: Bool) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .storePin:
            config = GiftCardWidgetConfig(
                accessToken: config.accessToken,
                storePin: value,
                activePrimaryButton: config.activePrimaryButton,
                showSubmitButton: config.showSubmitButton
            )
        case .activePrimaryButton:
            config = GiftCardWidgetConfig(
                accessToken: config.accessToken,
                storePin: config.storePin,
                activePrimaryButton: value,
                showSubmitButton: config.showSubmitButton
            )
        case .showSubmitButton:
            config = GiftCardWidgetConfig(
                accessToken: config.accessToken,
                storePin: config.storePin,
                activePrimaryButton: config.activePrimaryButton,
                showSubmitButton: value
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .giftCard, with: config)
    }

    private func updateAddressConfiguration(with value: Bool) {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .address, as: AddressWidgetConfig.self) else { return }

        switch configKey {
        case .activePrimaryButton:
            let updated = AddressWidgetConfig(address: config.address, activePrimaryButton: value)
            configVM.updateConfiguration(for: .address, with: updated)
        default:
            return
        }
    }

    private func updatePayPalConfiguration(with value: Bool) {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

        switch configKey {
        case .requestShipping:
            config = PayPalWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                requestShipping: value,
                fundingSource: config.fundingSource
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .paypal, with: config)
    }

    private func updateZipConfiguration(with value: Bool) {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return }

        let updatedConfig: ZipWidgetConfig

        switch configKey {
        case .tokenize:
            updatedConfig = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: value,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
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

    private func resetToDefault() {
        if isResettableConfigKey(configKey, for: selectedWidget) {
            toggleValue = true
        }
        updateConfiguration(with: toggleValue)
    }

    /// Whether `configKey` is one of the toggle-backed keys for `widget` — i.e. whether resetting
    /// this widget's config should reset this toggle's value.
    private func isResettableConfigKey(_ configKey: ConfigKeys?, for widget: ConfigWidgetsEnum) -> Bool {
        guard let configKey else { return false }
        switch widget {
        case .card:
            switch configKey {
            case .collectCardholderName, .activePrimaryButton, .showSubmitButton: return true
            default: return false
            }
        case .giftCard:
            switch configKey {
            case .storePin, .activePrimaryButton, .showSubmitButton: return true
            default: return false
            }
        case .address:
            return configKey == .activePrimaryButton
        case .paypal:
            return configKey == .requestShipping
        case .zip:
            return configKey == .tokenize
        default:
            return false
        }
    }
}
