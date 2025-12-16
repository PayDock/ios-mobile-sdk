//
//  ConfigToggleView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigToggleView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var toggleValue: Bool = false

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys
    let title: String

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
            if let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
                switch configKey {
                case .showCardTitle:
                    toggleValue = config.showCardTitle
                case .collectCardholderName:
                    toggleValue = config.collectCardholderName
                default:
                    break
                }
            }
        case .giftCard:
            if let config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) {
                switch configKey {
                case .storePin:
                    toggleValue = config.storePin
                default:
                    break
                }
            }
        case .paypal:
            if let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
                switch configKey {
                case .requestShipping:
                    toggleValue = config.requestShipping
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
        default:
            break
        }
    }

    private func updateCardConfiguration(with value: Bool) {
        guard var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) else { return }

        switch configKey {
        case .showCardTitle:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                showCardTitle: value,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                schemeSupport: config.schemeSupport
            )
        case .collectCardholderName:
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                showCardTitle: config.showCardTitle,
                collectCardholderName: value,
                allowSaveCard: config.allowSaveCard,
                schemeSupport: config.schemeSupport
            )
        default:
            return
        }
        configVM.updateConfiguration(for: .card, with: config)
    }

    private func updateGiftCardConfiguration(with value: Bool) {
        guard var config = configVM.getConfiguration(for: .giftCard, as: GiftCardWidgetConfig.self) else { return }

        switch configKey {
        case .storePin:
            config = GiftCardWidgetConfig(accessToken: config.accessToken, storePin: value)
        default:
            return
        }
        configVM.updateConfiguration(for: .giftCard, with: config)
    }

    private func updatePayPalConfiguration(with value: Bool) {
        guard var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) else { return }

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

    private func resetToDefault() {
        switch selectedWidget {
        case .card:
            switch configKey {
            case .showCardTitle:
                toggleValue = true
            case .collectCardholderName:
                toggleValue = true
            default:
                break
            }
        case .giftCard:
            switch configKey {
            case .storePin:
                toggleValue = true
            default:
                break
            }
        case .paypal:
            switch configKey {
            case .requestShipping:
                toggleValue = true
            default:
                break
            }
        default:
            break
        }
        updateConfiguration(with: toggleValue)
    }
}
