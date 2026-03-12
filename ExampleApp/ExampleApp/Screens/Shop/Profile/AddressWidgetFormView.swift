//
//  AddressWidgetFormView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AddressWidgetFormView: View {
    let editingAddress: SavedAddress?
    let onSave: (SavedAddress) -> Void
    let onCancel: () -> Void

    @State private var label: String = ""
    @State private var isDefault: Bool = false
    @State var addressResult: Address?
    @State private var showingAddressWidget = false

    var isEditing: Bool {
        return editingAddress != nil
    }

    var canSave: Bool {
        return !label.isEmpty && addressResult != nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isEditing ? "Edit Address" : "Add New Address")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 16) {
                    TextField("Address Label (e.g., Home, Work)", text: $label)
                        .accessibilityIdentifier("Address Label Field")
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle("Set as default address", isOn: $isDefault)
                        .accessibilityIdentifier("Set as default address")

                    if let result = addressResult {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Address:")
                                    .font(.headline)

                                Text(formatAddress(result))
                                    .font(.body)
                                    .padding()
                                    .background(Color(.systemGroupedBackground))
                                    .cornerRadius(8)

                                Button("Change Address") {
                                    showingAddressWidget = true
                                }
                                .accessibilityIdentifier("Change Address")
                                .font(.system(size: 14))
                                .foregroundColor(.defaultPrimary)
                            }
                            Spacer()
                        }
                    } else {
                        Button("Enter Address") {
                            showingAddressWidget = true
                        }
                        .accessibilityIdentifier("Enter Address")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.defaultPrimary)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .accessibilityIdentifier("Cancel Address Form")
                    .foregroundColor(.defaultPrimary)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.defaultPrimary, lineWidth: 1)
                    )

                    Button("Save") {
                        saveAddress()
                    }
                    .accessibilityIdentifier("Save Address")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(canSave ? Color.defaultPrimary : Color.gray)
                    .cornerRadius(8)
                    .disabled(!canSave)
                }
                .padding()
            }
            .sheet(isPresented: $showingAddressWidget) {
                AddressWidgetContainerView(address: addressResult) { address in
                    addressResult = address
                    showingAddressWidget = false
                }
            }
        }
        .onAppear {
            setupInitialData()
        }
    }

    private func setupInitialData() {
        if let editingAddress = editingAddress {
            label = editingAddress.label
            isDefault = editingAddress.isDefault

            // Convert SavedAddress to AddressResult for display
            addressResult = Address(
                firstName: editingAddress.firstName,
                lastName: editingAddress.lastName,
                addressLine1: editingAddress.addressLine1,
                addressLine2: editingAddress.addressLine2,
                city: editingAddress.city,
                state: editingAddress.state,
                postcode: editingAddress.postalCode,
                country: editingAddress.country
            )
        }
    }

    private func saveAddress() {
        guard let result = addressResult else { return }

        let savedAddress = SavedAddress(
            label: label,
            firstName: result.firstName,
            lastName: result.lastName,
            addressLine1: result.addressLine1,
            addressLine2: result.addressLine2,
            city: result.city,
            state: result.state,
            postalCode: result.postcode,
            country: result.country,
            isDefault: isDefault
        )

        onSave(savedAddress)
    }

    private func formatAddress(_ result: Address) -> String {
        var components: [String] = []

        components.append("\(result.firstName) \(result.lastName)")
        components.append(result.addressLine1)
        if !result.addressLine2.isEmpty {
            components.append(result.addressLine2)
        }
        components.append("\(result.city), \(result.state)")
        components.append(result.postcode)
        components.append(result.country)

        return components.joined(separator: "\n")
    }
}
