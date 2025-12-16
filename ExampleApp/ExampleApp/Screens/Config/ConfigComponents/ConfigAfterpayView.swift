//
//  ConfigAfterpayView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigAfterpayView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var minimumAmount: String = ""
    @State private var maximumAmount: String = "1000"
    @State private var currency: String = "AUD"
    @State private var language: String = "en_AU"
    @State private var country: String = "AU"

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack(spacing: 16) {
                        DimensionsFieldView(title: "Minimum Amount (Optional)", text: $minimumAmount)
                        DimensionsFieldView(title: "Maximum Amount", text: $maximumAmount)

                        HStack(spacing: 12) {
                            DimensionsFieldView(title: "Currency", text: $currency)
                            DimensionsFieldView(title: "Language", text: $language)
                        }

                        DimensionsFieldView(title: "Country", text: $country)
                    }
                    .padding(.top, 24)
                    .onChange(of: minimumAmount) { _ in updateConfiguration() }
                    .onChange(of: maximumAmount) { _ in updateConfiguration() }
                    .onChange(of: currency) { _ in updateConfiguration() }
                    .onChange(of: language) { _ in updateConfiguration() }
                    .onChange(of: country) { _ in updateConfiguration() }

                    ResetStyleButton {
                        resetToDefault()
                    }
                }
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
        if let config = configVM.getConfiguration(for: .afterPay, as: AfterpaySdkConfig.self) {
            minimumAmount = config.config.minimumAmount ?? ""
            maximumAmount = config.config.maximumAmount
            currency = config.config.currency
            language = config.config.language
            country = config.config.country
        }
    }

    private func updateConfiguration() {
        let afterpayConfig = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: minimumAmount.isEmpty ? nil : minimumAmount,
            maximumAmount: maximumAmount,
            currency: currency,
            language: language,
            country: country
        )

        // Get existing checkout options or use defaults
        let existingConfig = configVM.getConfiguration(for: .afterPay, as: AfterpaySdkConfig.self)
        let checkoutOptions = existingConfig?.options ?? AfterpaySdkConfig.CheckoutOptions()

        let sdkConfig = AfterpaySdkConfig(
            config: afterpayConfig,
            environment: existingConfig?.environment ?? .sandbox,
            options: checkoutOptions
        )

        configVM.updateConfiguration(for: .afterPay, with: sdkConfig)
    }

    private func resetToDefault() {
        minimumAmount = ""
        maximumAmount = "1000"
        currency = "AUD"
        language = "en_AU"
        country = "AU"
        updateConfiguration()
    }
}
