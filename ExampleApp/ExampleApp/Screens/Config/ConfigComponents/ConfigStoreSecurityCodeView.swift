//
//  ConfigStoreSecurityCodeView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigStoreSecurityCodeView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var isEnabled: Bool = false
    @State private var storeSecurityCodeValue: Bool = true

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionTitleView(title: "Store Security Code Configuration")

                    ToggleFieldView(
                        title: "Enable Store Security Code",
                        isOn: $isEnabled,
                        onChange: updateConfiguration
                    )

                    if isEnabled {
                        Divider()
                            .padding(.horizontal, 16)

                        ToggleFieldView(
                            title: "Store Security Code",
                            isOn: $storeSecurityCodeValue,
                            onChange: updateConfiguration
                        )
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
            if let storeSecurityCode = config.storeSecurityCode {
                isEnabled = true
                storeSecurityCodeValue = storeSecurityCode
            } else {
                isEnabled = false
                storeSecurityCodeValue = true // Default value when enabled
            }
        }
    }

    private func updateConfiguration() {
        if var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
            let storeSecurityCode: Bool? = isEnabled ? storeSecurityCodeValue : nil

            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: storeSecurityCode,
                schemeSupport: config.schemeSupport,
                activePrimaryButton: config.activePrimaryButton
            )
            configVM.updateConfiguration(for: .card, with: config)
        }
    }

    private func resetToDefault() {
        isEnabled = false
        storeSecurityCodeValue = true
        updateConfiguration()
    }
}
