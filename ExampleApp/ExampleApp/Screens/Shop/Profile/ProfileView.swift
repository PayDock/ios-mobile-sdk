//
//  ProfileView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ProfileView: View {
    @StateObject private var viewModel = ProfileVM()
    @StateObject private var profileManager = UserProfileManager.shared
    @State private var showingAddressWidget = false
    @State private var editingAddress: SavedAddress?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Info Section
                profileInfoSection

                // Saved Payment Methods Section
                savedPaymentMethodsSection

                // Saved Addresses Section
                savedAddressesSection
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddressWidget) {
            AddressWidgetFormView(
                editingAddress: nil,
                onSave: { address in
                    saveAddress(address)
                    showingAddressWidget = false
                },
                onCancel: {
                    editingAddress = nil
                    showingAddressWidget = false
                },
                addressResult: nil
            )
        }
        .sheet(item: $editingAddress) { selectedAddress in
            AddressWidgetFormView(
                editingAddress: selectedAddress,
                onSave: { address in
                    saveAddress(address)
                    editingAddress = nil
                },
                onCancel: {
                    editingAddress = nil
                },
                addressResult: getAddressFromSavedAddress(selectedAddress)
            )
        }
        .alert(viewModel.showAlert ? viewModel.alertTitle : "Address", isPresented: $viewModel.showAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.showAlert ? viewModel.alertMessage : alertMessage)
        }
        .alert("Address", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    private func getAddressFromSavedAddress(_ savedAddress: SavedAddress?) -> Address? {
        guard let savedAddress = savedAddress else { return nil }
        return Address(
            firstName: savedAddress.firstName,
            lastName: savedAddress.lastName,
            addressLine1: savedAddress.addressLine1,
            addressLine2: savedAddress.addressLine2,
            city: savedAddress.city,
            state: savedAddress.state,
            postcode: savedAddress.postalCode,
            country: savedAddress.country)
    }

    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("First Name", text: $profileManager.profile.firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Last Name", text: $profileManager.profile.lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                TextField("Email", text: $profileManager.profile.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                TextField("Phone", text: $profileManager.profile.phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            }

            Button("Save Changes") {
                profileManager.updateProfile(
                    firstName: profileManager.profile.firstName,
                    lastName: profileManager.profile.lastName,
                    email: profileManager.profile.email,
                    phone: profileManager.profile.phone
                )
                alertMessage = "Profile updated successfully!"
                showAlert = true
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(Color.defaultPrimary)
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var savedPaymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Payment Methods")
                .font(.title2)
                .fontWeight(.bold)

            VStack {
                HStack {
                    Image("payPal")
                        .padding([.top, .leading, .trailing], 16)
                    Spacer()
                }

                if viewModel.isCustomerLinked, let customerInfo = viewModel.linkedCustomerInfo {
                    // Show linked customer information
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Account Linked")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(customerInfo.firstName) \(customerInfo.lastName)")
                                .font(.system(size: 15, weight: .medium))
                            Text("\(customerInfo.phone)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            if let email = customerInfo.email {
                                Text(email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button("Unlink Account") {
                            viewModel.unlinkCustomer()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                } else {
                    // Show link account message and widget
                    Text("Link your PayPal account to use method next time you shop")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        .padding([.leading, .trailing], 16)
                    vaultWidget()
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10.0)
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var savedAddressesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Saved Addresses")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button("Add Address") {
                    editingAddress = nil
                    showingAddressWidget = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.defaultPrimary)
            }

            if profileManager.profile.savedAddresses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "location")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("No saved addresses")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("Add an address to speed up checkout")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button("Add Your First Address") {
                        editingAddress = nil
                        showingAddressWidget = true
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.defaultPrimary)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(profileManager.profile.savedAddresses) { address in
                    SavedAddressCardView(
                        address: address,
                        onEdit: {
                            print(address)
                            editingAddress = address
                        },
                        onDelete: {
                            deleteAddress(address)
                        },
                        onSetDefault: {
                            profileManager.setAddressAsDefault(address)
                            alertMessage = "Default address updated!"
                            showAlert = true
                        }
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private func vaultWidget() -> some View {
        PayPalSavePaymentSourceWidget(
            config: viewModel.getVaultConfig(),
            appearance: viewModel.getVaultAppearance()) { result in
            switch result {
            case let .success(result):
                viewModel.createCustomer(payPalVaultResult: result)
            case let .failure(error):
                viewModel.handleError(error: error)
            }
        }
        .padding()
        .padding(.bottom, 8)
    }

    private func saveAddress(_ address: SavedAddress) {
        if let editingAddress = editingAddress {
            // Update existing address
            var updatedAddress = address
            updatedAddress.id = editingAddress.id
            profileManager.updateAddress(updatedAddress)
            alertMessage = "Address updated successfully!"
        } else {
            // Add new address
            profileManager.addAddress(address)
            alertMessage = "Address added successfully!"
        }

        showAlert = true
        editingAddress = nil
    }

    private func deleteAddress(_ address: SavedAddress) {
        profileManager.deleteAddress(address)
        alertMessage = "Address deleted successfully!"
        showAlert = true
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
