//
//  ConfigSaveCardView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigSaveCardView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var isEnabled: Bool = false
    @State private var consentText: String = "Remember this card for next time."
    @State private var privacyPolicyText: String = "Read our privacy policy"
    @State private var privacyPolicyURL: String = "https://www.google.com"

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionTitleView(title: "Save Card Configuration")

                    ToggleFieldView(
                        title: "Enable Save Card",
                        isOn: $isEnabled,
                        onChange: updateConfiguration
                    )

                    if isEnabled {
                        VStack(spacing: 16) {
                            DimensionsFieldView(
                                title: "Consent Text",
                                text: $consentText
                            )

                            DimensionsFieldView(
                                title: "Privacy Policy Text",
                                text: $privacyPolicyText
                            )

                            DimensionsFieldView(
                                title: "Privacy Policy URL",
                                text: $privacyPolicyURL
                            )
                        }
                        .onChange(of: consentText) { _ in updateConfiguration() }
                        .onChange(of: privacyPolicyText) { _ in updateConfiguration() }
                        .onChange(of: privacyPolicyURL) { _ in updateConfiguration() }
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
        .foregroundColor(.black)
        .onAppear {
            loadCurrentValue()
        }
    }

    private func loadCurrentValue() {
        if let config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
            if let saveCardConfig = config.allowSaveCard {
                isEnabled = true
                consentText = saveCardConfig.consentText ?? "Remember this card for next time."
                privacyPolicyText = saveCardConfig.privacyPolicyConfig?.privacyPolicyText ?? "Read our privacy policy"
                privacyPolicyURL = saveCardConfig.privacyPolicyConfig?.privacyPolicyURL ?? "https://www.google.com"
            } else {
                isEnabled = false
            }
        }
    }

    private func updateConfiguration() {
        if var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
            let saveCardConfig: SaveCardConfig? = isEnabled ? SaveCardConfig(
                consentText: consentText.isEmpty ? nil : consentText,
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: privacyPolicyText,
                    privacyPolicyURL: privacyPolicyURL
                )
            ) : nil

            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: saveCardConfig,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton
            )
            configVM.updateConfiguration(for: .card, with: config)
        }
    }

    private func resetToDefault() {
        isEnabled = true
        consentText = "Remember this card for next time."
        privacyPolicyText = "Read our privacy policy"
        privacyPolicyURL = "https://www.google.com"
        updateConfiguration()
    }
}
