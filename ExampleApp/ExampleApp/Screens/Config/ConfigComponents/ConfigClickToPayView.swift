//
//  ConfigClickToPayView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigClickToPayView: View {

    @EnvironmentObject var configVM: ConfigVM

    // ClickToPayMeta fields
    @State private var disableSummaryScreen: Bool = false
    @State private var selectedCardBrands: Set<CardBrands> = []
    @State private var coBrandNamesText: String = ""
    @State private var checkoutExperience: CheckoutExperience = .withingCheckout
    @State private var services: Services = .inlineCheckout

    // DPA Data fields
    @State private var dpaAddress: String = ""
    @State private var dpaEmailAddress: String = ""
    @State private var dpaPhoneCountryCode: String = ""
    @State private var dpaPhoneNumber: String = ""
    @State private var dpaLogoUri: String = ""
    @State private var dpaSupportedEmailAddress: String = ""
    @State private var dpaSupportedPhoneCountryCode: String = ""
    @State private var dpaSupportedPhoneNumber: String = ""
    @State private var dpaUri: String = ""
    @State private var dpaSupportUri: String = ""
    @State private var applicationType: ApplicationType = .mobileApp

    let selectedWidget: ConfigWidgetsEnum
    let title: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Meta Configuration
                    VStack(spacing: 16) {
                        SectionTitleView(title: "Meta Configuration")

                        ToggleFieldView(title: "Disable Summary Screen", isOn: $disableSummaryScreen, onChange: updateConfiguration)

                        // Checkout Experience Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Checkout Experience")
                                .padding(.leading, 16)
                                .font(.body)

                            Picker("", selection: $checkoutExperience) {
                                Text("Within Checkout").tag(CheckoutExperience.withingCheckout)
                                Text("Payment Settings").tag(CheckoutExperience.paymentSettings)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                        }

                        // Services Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Services")
                                .padding(.leading, 16)
                                .font(.body)

                            Picker("", selection: $services) {
                                Text("Inline Checkout").tag(Services.inlineCheckout)
                                Text("Inline Installments").tag(Services.inlineInstallments)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                        }

                        // Card Brands Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Supported Card Brands")
                                .padding(.leading, 16)
                                .font(.body)

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach([CardBrands.mastercard, .maestro, .visa, .amex, .discover], id: \.self) { brand in
                                    ToggleFieldView(
                                        title: brand.rawValue.capitalized,
                                        isOn: Binding(
                                            get: { selectedCardBrands.contains(brand) },
                                            set: { isOn in
                                                if isOn {
                                                    selectedCardBrands.insert(brand)
                                                } else {
                                                    selectedCardBrands.remove(brand)
                                                }
                                                updateConfiguration()
                                            }
                                        ),
                                        onChange: {}
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }

                        DimensionsFieldView(title: "Co-Brand Names (comma separated)", text: $coBrandNamesText)
                    }

                    // DPA Data Configuration (Optional)
                    VStack(spacing: 16) {
                        SectionTitleView(title: "DPA Data Configuration (Optional)")

                        DimensionsFieldView(title: "DPA Address", text: $dpaAddress)
                        DimensionsFieldView(title: "DPA Email Address", text: $dpaEmailAddress)

                        HStack(spacing: 12) {
                            DimensionsFieldView(title: "Phone Country Code", text: $dpaPhoneCountryCode)
                            DimensionsFieldView(title: "Phone Number", text: $dpaPhoneNumber)
                        }

                        DimensionsFieldView(title: "DPA Logo URI", text: $dpaLogoUri)
                        DimensionsFieldView(title: "DPA Supported Email", text: $dpaSupportedEmailAddress)

                        HStack(spacing: 12) {
                            DimensionsFieldView(title: "Support Phone Country", text: $dpaSupportedPhoneCountryCode)
                            DimensionsFieldView(title: "Support Phone Number", text: $dpaSupportedPhoneNumber)
                        }

                        DimensionsFieldView(title: "DPA URI", text: $dpaUri)
                        DimensionsFieldView(title: "DPA Support URI", text: $dpaSupportUri)

                        // Application Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Application Type")
                                .padding(.leading, 16)
                                .font(.body)

                            Picker("", selection: $applicationType) {
                                Text("Mobile App").tag(ApplicationType.mobileApp)
                                Text("Web Browser").tag(ApplicationType.webBrowser)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16.0)
                    }
                }
                .padding(.top, 24)
                .onChange(of: disableSummaryScreen) { _ in updateConfiguration() }
                .onChange(of: checkoutExperience) { _ in updateConfiguration() }
                .onChange(of: services) { _ in updateConfiguration() }
                .onChange(of: coBrandNamesText) { _ in updateConfiguration() }
                .onChange(of: dpaAddress) { _ in updateConfiguration() }
                .onChange(of: dpaEmailAddress) { _ in updateConfiguration() }
                .onChange(of: dpaPhoneCountryCode) { _ in updateConfiguration() }
                .onChange(of: dpaPhoneNumber) { _ in updateConfiguration() }
                .onChange(of: dpaLogoUri) { _ in updateConfiguration() }
                .onChange(of: dpaSupportedEmailAddress) { _ in updateConfiguration() }
                .onChange(of: dpaSupportedPhoneCountryCode) { _ in updateConfiguration() }
                .onChange(of: dpaSupportedPhoneNumber) { _ in updateConfiguration() }
                .onChange(of: dpaUri) { _ in updateConfiguration() }
                .onChange(of: dpaSupportUri) { _ in updateConfiguration() }
                .onChange(of: applicationType) { _ in updateConfiguration() }
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
        if let config = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) {
            if let meta = config.meta {
                disableSummaryScreen = meta.disableSummaryScreen ?? false
                checkoutExperience = meta.checkoutExperience ?? .withingCheckout
                services = meta.services ?? .inlineCheckout

                if let cardBrands = meta.cardBrands {
                    selectedCardBrands = Set(cardBrands)
                }

                if let coBrandNames = meta.coBrandNames {
                    coBrandNamesText = coBrandNames.joined(separator: ", ")
                }

                if let dpaData = meta.dpaData {
                    dpaAddress = dpaData.dpaAddress ?? ""
                    dpaEmailAddress = dpaData.dpaEmailAddress ?? ""

                    if let phoneNumber = dpaData.dpaPhoneNumber {
                        dpaPhoneCountryCode = phoneNumber.countryCode
                        dpaPhoneNumber = phoneNumber.phoneNumber
                    }

                    dpaLogoUri = dpaData.dpaLogoUri ?? ""
                    dpaSupportedEmailAddress = dpaData.dpaSupportedEmailAddress ?? ""

                    if let supportPhone = dpaData.dpaSupportedPhoneNumber {
                        dpaSupportedPhoneCountryCode = supportPhone.countryCode
                        dpaSupportedPhoneNumber = supportPhone.phoneNumber
                    }

                    dpaUri = dpaData.dpaUri ?? ""
                    dpaSupportUri = dpaData.dpaSupportUri ?? ""
                    applicationType = dpaData.applicationType ?? .mobileApp
                }
            }
        }
    }

    // swiftlint:disable:next function_body_length
    private func updateConfiguration() {
        // Get existing config for serviceId and accessToken
        guard let existingConfig = configVM.getConfiguration(for: .clickToPay, as: ClickToPayWidgetConfig.self) else { return }

        // Build PhoneNumber objects if fields are populated
        let phoneNumber: PhoneNumber? = {
            if !dpaPhoneCountryCode.isEmpty && !dpaPhoneNumber.isEmpty {
                return PhoneNumber(countryCode: dpaPhoneCountryCode, phoneNumber: dpaPhoneNumber)
            }
            return nil
        }()

        let supportPhoneNumber: PhoneNumber? = {
            if !dpaSupportedPhoneCountryCode.isEmpty && !dpaSupportedPhoneNumber.isEmpty {
                return PhoneNumber(countryCode: dpaSupportedPhoneCountryCode, phoneNumber: dpaSupportedPhoneNumber)
            }
            return nil
        }()

        // Build DPA Data if any field is populated
        let dpaData: ClickToPayDPAData? = {
            if !dpaAddress.isEmpty || !dpaEmailAddress.isEmpty || phoneNumber != nil ||
                !dpaLogoUri.isEmpty || !dpaSupportedEmailAddress.isEmpty || supportPhoneNumber != nil ||
                !dpaUri.isEmpty || !dpaSupportUri.isEmpty {

                var data = ClickToPayDPAData()
                data.dpaAddress = dpaAddress.isEmpty ? nil : dpaAddress
                data.dpaEmailAddress = dpaEmailAddress.isEmpty ? nil : dpaEmailAddress
                data.dpaPhoneNumber = phoneNumber
                data.dpaLogoUri = dpaLogoUri.isEmpty ? nil : dpaLogoUri
                data.dpaSupportedEmailAddress = dpaSupportedEmailAddress.isEmpty ? nil : dpaSupportedEmailAddress
                data.dpaSupportedPhoneNumber = supportPhoneNumber
                data.dpaUri = dpaUri.isEmpty ? nil : dpaUri
                data.dpaSupportUri = dpaSupportUri.isEmpty ? nil : dpaSupportUri
                data.applicationType = applicationType

                return data
            }
            return nil
        }()

        // Parse co-brand names
        let coBrandNames: [String]? = {
            let trimmed = coBrandNamesText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return nil }
            return trimmed.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }()

        // Build meta object - only include if any field has a value
        let meta: ClickToPayMeta? = {
            // Check if we have any meta configuration
            if disableSummaryScreen || !selectedCardBrands.isEmpty || coBrandNames != nil || dpaData != nil {
                return ClickToPayMeta(
                    dpaData: dpaData,
                    disableSummaryScreen: disableSummaryScreen ? true : nil,
                    cardBrands: selectedCardBrands.isEmpty ? nil : Array(selectedCardBrands),
                    coBrandNames: coBrandNames,
                    checkoutExperience: checkoutExperience,
                    services: services,
                    dpaTransactionOptions: nil  // Can be extended when ClickToPayDPAOptions structure is known
                )
            }
            return nil
        }()

        let config = ClickToPayWidgetConfig(
            serviceId: existingConfig.serviceId,
            accessToken: existingConfig.accessToken,
            meta: meta
        )

        configVM.updateConfiguration(for: .clickToPay, with: config)
    }
}
