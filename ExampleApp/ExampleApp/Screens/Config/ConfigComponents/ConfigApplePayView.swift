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
    @State private var validationMode: String = ApplePayValidationMode.none.rawValue

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

                        PickerView(
                            entries: ApplePayValidationMode.allCases.map(\.rawValue),
                            selected: $validationMode,
                            placeholder: "Validation Callback",
                            onSelection: { _ in updateConfiguration() }
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
        validationMode = ConfigManager.shared.getApplePayConfigParams().validationMode.rawValue

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
            performAvailabilityChecks: performAvailabilityChecks,
            validationMode: ApplePayValidationMode(rawValue: validationMode) ?? .none
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
        validationMode = ApplePayValidationMode.none.rawValue
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
    let validationMode: ApplePayValidationMode

    init(serviceId: String,
         amountLabel: String,
         countryCode: String,
         merchantIdentifier: String,
         requireBillingAddress: Bool,
         requireShippingAddress: Bool,
         showSetupButtonIfRequired: Bool,
         performAvailabilityChecks: Bool,
         validationMode: ApplePayValidationMode = .none) {
        self.serviceId = serviceId
        self.amountLabel = amountLabel
        self.countryCode = countryCode
        self.merchantIdentifier = merchantIdentifier
        self.requireBillingAddress = requireBillingAddress
        self.requireShippingAddress = requireShippingAddress
        self.showSetupButtonIfRequired = showSetupButtonIfRequired
        self.performAvailabilityChecks = performAvailabilityChecks
        self.validationMode = validationMode
    }

    // Configs saved before validationMode existed decode with the default.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        serviceId = try container.decode(String.self, forKey: .serviceId)
        amountLabel = try container.decode(String.self, forKey: .amountLabel)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        merchantIdentifier = try container.decode(String.self, forKey: .merchantIdentifier)
        requireBillingAddress = try container.decode(Bool.self, forKey: .requireBillingAddress)
        requireShippingAddress = try container.decode(Bool.self, forKey: .requireShippingAddress)
        showSetupButtonIfRequired = try container.decode(Bool.self, forKey: .showSetupButtonIfRequired)
        performAvailabilityChecks = try container.decode(Bool.self, forKey: .performAvailabilityChecks)
        validationMode = try container.decodeIfPresent(ApplePayValidationMode.self, forKey: .validationMode) ?? .none
    }
}

// MARK: - ApplePayValidationMode

/// Which `onShouldPresentPaymentSheet` hook the sample attaches to `ApplePayWidget`.
enum ApplePayValidationMode: String, Codable, CaseIterable {
    case none = "No validation callback"
    case succeed = "Validation succeeds"
    case fail = "Validation fails"
}
