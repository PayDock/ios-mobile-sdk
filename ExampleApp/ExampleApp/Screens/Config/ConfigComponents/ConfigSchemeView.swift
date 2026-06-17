//
//  ConfigSchemeView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigSchemeView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var supportedSchemes: Set<CardScheme> = Set(CardScheme.allCases)
    @State private var enableValidation: Bool = true

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionTitleView(title: "Supported Schemes")

                    VStack(spacing: 16) {
                        ForEach(CardScheme.allCases, id: \.self) { scheme in
                            ToggleFieldView(
                                title: scheme.rawValue.capitalized,
                                isOn: Binding(
                                    get: { supportedSchemes.contains(scheme) },
                                    set: { isOn in
                                        if isOn {
                                            supportedSchemes.insert(scheme)
                                        } else {
                                            supportedSchemes.remove(scheme)
                                        }
                                        updateConfiguration()
                                    }
                                ),
                                onChange: {}
                            )
                        }
                    }

                    SectionTitleView(title: "Validation")

                    ToggleFieldView(
                        title: "Enable Validation",
                        isOn: $enableValidation,
                        onChange: updateConfiguration
                    )

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
            supportedSchemes = config.schemeSupport.supportedSchemes ?? Set(CardScheme.allCases)
            enableValidation = config.schemeSupport.enableValidation
        }
    }

    private func updateConfiguration() {
        if var config = configVM.getConfiguration(for: .card, as: CardDetailsWidgetConfig.self) {
            let schemeSupport = SupportedSchemesConfig(
                supportedSchemes: supportedSchemes,
                enableValidation: enableValidation
            )
            config = CardDetailsWidgetConfig(
                gatewayId: config.gatewayId,
                accessToken: config.accessToken,
                collectCardholderName: config.collectCardholderName,
                allowSaveCard: config.allowSaveCard,
                storeSecurityCode: config.storeSecurityCode,
                schemeSupport: schemeSupport,
                activePrimaryButton: config.activePrimaryButton
            )
            configVM.updateConfiguration(for: .card, with: config)
        }
    }

    private func resetToDefault() {
        supportedSchemes = Set(CardScheme.allCases)
        enableValidation = true
        updateConfiguration()
    }
}
