//
//  ConfigCheckoutOptionsView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigCheckoutOptionsView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var pickup: Bool = false
    @State private var buyNow: Bool = false
    @State private var shippingOptionRequired: Bool = false
    @State private var enableSingleShippingOptionUpdate: Bool = false

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        ToggleFieldView(
                            title: "Pickup",
                            isOn: $pickup,
                            onChange: updateConfiguration
                        )

                        ToggleFieldView(
                            title: "Buy Now",
                            isOn: $buyNow,
                            onChange: updateConfiguration
                        )

                        ToggleFieldView(
                            title: "Shipping Option Required",
                            isOn: $shippingOptionRequired,
                            onChange: updateConfiguration
                        )

                        ToggleFieldView(
                            title: "Enable Single Shipping Option Update",
                            isOn: $enableSingleShippingOptionUpdate,
                            onChange: updateConfiguration
                        )
                    }
                    .padding(.vertical, 12)

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
        if let config = configVM.getConfiguration(for: .afterPay, as: AfterpaySdkConfig.self) {
            pickup = config.options.pickup ?? false
            buyNow = config.options.buyNow ?? false
            shippingOptionRequired = config.options.shippingOptionRequired ?? false
            enableSingleShippingOptionUpdate = config.options.enableSingleShippingOptionUpdate ?? false
        }
    }

    private func updateConfiguration() {
        let checkoutOptions = AfterpaySdkConfig.CheckoutOptions(
            pickup: pickup,
            buyNow: buyNow,
            shippingOptionRequired: shippingOptionRequired,
            enableSingleShippingOptionUpdate: enableSingleShippingOptionUpdate
        )

        // Get existing configuration or use defaults
        let existingConfig = configVM.getConfiguration(for: .afterPay, as: AfterpaySdkConfig.self)

        let sdkConfig = AfterpaySdkConfig(
            environment: existingConfig?.environment ?? .sandbox,
            options: checkoutOptions
        )

        configVM.updateConfiguration(for: .afterPay, with: sdkConfig)
    }

    private func resetToDefault() {
        pickup = false
        buyNow = false
        shippingOptionRequired = false
        enableSingleShippingOptionUpdate = false
        updateConfiguration()
    }
}
