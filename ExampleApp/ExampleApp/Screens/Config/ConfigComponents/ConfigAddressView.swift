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
    let title: String

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

    private func updateConfiguration() {
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

        let config = AddressWidgetConfig(address: address)
        configVM.updateConfiguration(for: .address, with: config)
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
