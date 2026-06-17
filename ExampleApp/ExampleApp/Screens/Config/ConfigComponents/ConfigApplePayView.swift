//
//  ConfigApplePayView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ConfigApplePayView: View {

    @EnvironmentObject var configVM: ConfigVM

    @State private var serviceId: String = ""
    @State private var amountLabel: String = "Amount"
    @State private var countryCode: String = "AU"
    @State private var merchantIdentifier: String = ""
    @State private var requireBillingAddress: Bool = false
    @State private var requireShippingAddress: Bool = false
    @State private var showSetupButtonIfRequired: Bool = false
    @State private var performAvailabilityChecks: Bool = true

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        DimensionsFieldView(title: "Service ID", text: $serviceId)
                            .onChange(of: serviceId) { _ in updateConfiguration() }

                        DimensionsFieldView(title: "Amount Label", text: $amountLabel)
                            .onChange(of: amountLabel) { _ in updateConfiguration() }

                        DimensionsFieldView(title: "Country Code", text: $countryCode)
                            .onChange(of: countryCode) { _ in updateConfiguration() }

                        DimensionsFieldView(title: "Merchant Identifier", text: $merchantIdentifier)
                            .onChange(of: merchantIdentifier) { _ in updateConfiguration() }

                        ToggleFieldView(title: "Require Billing Address", isOn: $requireBillingAddress, onChange: updateConfiguration)

                        ToggleFieldView(title: "Require Shipping Address", isOn: $requireShippingAddress, onChange: updateConfiguration)

                        ToggleFieldView(
                            title: "Show Setup Button If Required",
                            isOn: $showSetupButtonIfRequired,
                            onChange: updateConfiguration
                        )

                        ToggleFieldView(
                            title: "Perform Availability Checks",
                            isOn: $performAvailabilityChecks,
                            onChange: updateConfiguration
                        )
                    }
                    .padding(.top, 24)

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
        let config = ConfigManager.shared.getApplePayWidgetConfig()
        serviceId = config.serviceId

        // Extract values from PKPaymentRequest
        let paymentRequest = config.pkPaymentRequest
        countryCode = paymentRequest.countryCode
        merchantIdentifier = paymentRequest.merchantIdentifier
        requireBillingAddress = !paymentRequest.requiredBillingContactFields.isEmpty
        requireShippingAddress = !paymentRequest.requiredShippingContactFields.isEmpty
        showSetupButtonIfRequired = config.showSetUpButtonWhenNoCardsEnrolled
        performAvailabilityChecks = config.performAvailabilityChecks

        // Extract amountLabel from payment summary items
        if let firstItem = paymentRequest.paymentSummaryItems.first {
            amountLabel = firstItem.label
        }
    }

    private func updateConfiguration() {
        let config = ApplePayConfigParams(
            serviceId: serviceId,
            amountLabel: amountLabel,
            countryCode: countryCode,
            merchantIdentifier: merchantIdentifier,
            requireBillingAddress: requireBillingAddress,
            requireShippingAddress: requireShippingAddress,
            showSetupButtonIfRequired: showSetupButtonIfRequired,
            performAvailabilityChecks: performAvailabilityChecks
        )

        configVM.updateConfiguration(for: .applePay, with: config)
    }

    private func resetToDefault() {
        serviceId = ProjectEnvironment.shared.getApplePayServiceId() ?? ""
        amountLabel = "Amount"
        countryCode = "AU"
        merchantIdentifier = ProjectEnvironment.shared.getApplePayMerchantId() ?? ""
        requireBillingAddress = true
        requireShippingAddress = false
        showSetupButtonIfRequired = false
        performAvailabilityChecks = true
        updateConfiguration()
    }
}

// MARK: - ApplePayConfigParams

struct ApplePayConfigParams: Codable {
    let serviceId: String
    let amountLabel: String
    let countryCode: String
    let merchantIdentifier: String
    let requireBillingAddress: Bool
    let requireShippingAddress: Bool
    let showSetupButtonIfRequired: Bool
    let performAvailabilityChecks: Bool
}
