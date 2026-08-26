//
//  ConfigAddressView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK

struct ConfigAddressView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var line1: String = ""
    @State private var line2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var postcode: String = ""
    @State private var country: String = ""

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
                VStack {
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            DimensionsFieldView(title: "First Name", text: $firstName)
                            DimensionsFieldView(title: "Last Name", text: $lastName)
                        }

                        DimensionsFieldView(title: "Address Line 1", text: $line1)
                        DimensionsFieldView(title: "Address Line 2 (Optional)", text: $line2)

                        HStack(spacing: 0) {
                            DimensionsFieldView(title: "City", text: $city)
                            DimensionsFieldView(title: "State", text: $state)
                        }

                        HStack(spacing: 0) {
                            DimensionsFieldView(title: "Postcode", text: $postcode)
                            DimensionsFieldView(title: "Country", text: $country)
                        }
                    }
                    .onChange(of: firstName) { _ in updateConfiguration() }
                    .onChange(of: lastName) { _ in updateConfiguration() }
                    .onChange(of: line1) { _ in updateConfiguration() }
                    .onChange(of: line2) { _ in updateConfiguration() }
                    .onChange(of: city) { _ in updateConfiguration() }
                    .onChange(of: state) { _ in updateConfiguration() }
                    .onChange(of: postcode) { _ in updateConfiguration() }
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
        switch selectedWidget {
        case .address:
            loadAddressCurrentValue()
        case .zip:
            loadZipCurrentValue()
        default:
            break
        }
    }

    private func loadAddressCurrentValue() {
        if let config = configVM.getConfiguration(for: .address, as: AddressWidgetConfig.self),
           let address = config.address {
            firstName = address.firstName
            lastName = address.lastName
            line1 = address.addressLine1
            line2 = address.addressLine2
            city = address.city
            state = address.state
            postcode = address.postcode
            country = address.country
        }
    }

    private func loadZipCurrentValue() {
        guard let configKey = configKey,
              let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return }

        switch configKey {
        case .billingAddress:
            if let address = config.billing {
                firstName = address.firstName ?? ""
                lastName = address.lastName ?? ""
                line1 = address.line1 ?? ""
                line2 = address.line2 ?? ""
                city = address.city ?? ""
                state = address.state ?? ""
                postcode = address.postcode ?? ""
                country = address.country ?? ""
            }
        case .shippingAddress:
            if let address = config.shipping {
                firstName = address.firstName ?? ""
                lastName = address.lastName ?? ""
                line1 = address.line1 ?? ""
                line2 = address.line2 ?? ""
                city = address.city ?? ""
                state = address.state ?? ""
                postcode = address.postcode ?? ""
                country = address.country ?? ""
            }
        default:
            break
        }
    }

    private func updateConfiguration() {
        switch selectedWidget {
        case .address:
            updateAddressConfiguration()
        case .zip:
            updateZipConfiguration()
        default:
            break
        }
    }

    private func updateAddressConfiguration() {
        let address = Address(
            firstName: firstName.isEmpty ? "" : firstName,
            lastName: lastName.isEmpty ? "" : lastName,
            addressLine1: line1.isEmpty ? "" : line1,
            addressLine2: line2.isEmpty ? "" : line2,
            city: city.isEmpty ? "" : city,
            state: state.isEmpty ? "" : state,
            postcode: postcode.isEmpty ? "" : postcode,
            country: country.isEmpty ? "" : country
        )

        // Preserve the current activePrimaryButton setting when the prefilled address changes.
        let activePrimaryButton = configVM.getConfiguration(for: .address, as: AddressWidgetConfig.self)?.activePrimaryButton ?? true
        let config = AddressWidgetConfig(address: address, activePrimaryButton: activePrimaryButton)
        configVM.updateConfiguration(for: .address, with: config)
    }

    // swiftlint:disable:next function_body_length
    private func updateZipConfiguration() {
        guard let configKey = configKey,
              var config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) else { return }

        let address = ZipWidgetConfig.Address(
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            line1: line1.isEmpty ? nil : line1,
            line2: line2.isEmpty ? nil : line2,
            city: city.isEmpty ? nil : city,
            state: state.isEmpty ? nil : state,
            postcode: postcode.isEmpty ? nil : postcode,
            country: country.isEmpty ? nil : country
        )

        switch configKey {
        case .billingAddress:
            config = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: address,
                shipping: config.shipping,
                items: config.items,
                statistics: config.statistics
            )
        case .shippingAddress:
            config = ZipWidgetConfig(
                accessToken: config.accessToken,
                gatewayId: config.gatewayId,
                amount: config.amount,
                currency: config.currency,
                firstName: config.firstName,
                lastName: config.lastName,
                email: config.email,
                phone: config.phone,
                tokenize: config.tokenize,
                gender: config.gender,
                dateOfBirth: config.dateOfBirth,
                shippingType: config.shippingType,
                billing: config.billing,
                shipping: address,
                items: config.items,
                statistics: config.statistics
            )
        default:
            break
        }

        configVM.updateConfiguration(for: .zip, with: config)
    }

    private func resetToDefault() {
        firstName = ""
        lastName = ""
        line1 = ""
        line2 = ""
        city = ""
        state = ""
        postcode = ""
        country = ""
        updateConfiguration()
    }
}
