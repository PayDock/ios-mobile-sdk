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
        switch selectedWidget {
        case .card:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
                switch configKey {
                case .collectCardholderName:
                    toggleValue = config.collectCardholderName
                case .activePrimaryButton:
                    toggleValue = config.activePrimaryButton
                default:
                    break
                }
            }
        case .giftCard:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) {
                switch configKey {
                case .storePin:
                    toggleValue = config.storePin
                default:
                    break
                }
            }
        case .paypal:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
                switch configKey {
                case .requestShipping:
                    toggleValue = config.requestShipping
                default:
                    break
                }
            }
        case .zip:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) {
                switch configKey {
                case .tokenize:
                    toggleValue = config.tokenize ?? true
                default:
                    break
                }
            }
        default:
            break
        }
    }

    private func updateConfiguration(with value: Bool) {
        switch selectedWidget {
        case .card:
            updateCardConfiguration(with: value)
        case .giftCard:
            updateGiftCardConfiguration(with: value)
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
                activePrimaryButton: config.activePrimaryButton
            )
        case .activePrimaryButton:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: value
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
            config = GiftCardWidgetConfig(accessToken: config.accessToken, storePin: value)
        default:
            return
        }
        configVM.updateConfiguration(for: .giftCard, with: config)
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
        switch selectedWidget {
        case .card:
            if let configKey = configKey {
                switch configKey {
                case .collectCardholderName:
                    toggleValue = true
                case .activePrimaryButton:
                    toggleValue = true
                default:
                    break
                }
            }
        case .giftCard:
            if let configKey = configKey {
                switch configKey {
                case .storePin:
                    toggleValue = true
                default:
                    break
                }
            }
        case .paypal:
            if let configKey = configKey {
                switch configKey {
                case .requestShipping:
                    toggleValue = true
                default:
                    break
                }
            }
        case .zip:
                if let configKey = configKey {
                switch configKey {
                case .tokenize:
                    toggleValue = true
                default:
                    break
                }
            }
        default:
            break
        }
        updateConfiguration(with: toggleValue)
    }
}
