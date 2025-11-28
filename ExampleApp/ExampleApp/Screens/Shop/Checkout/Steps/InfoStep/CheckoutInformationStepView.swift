//
//  CheckoutInformationStepView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct CheckoutInformationStepView: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @ObservedObject var profileManager: UserProfileManager

    @StateObject private var cartManager = CartManager.shared
    @State private var showingGiftCardEntry = false

    let onLoadProfileData: () -> Void
    let onSelectSavedAddress: (SavedAddress, AddressWidgetType) -> Void
    let onClearShippingAddress: () -> Void
    let onClearBillingAddress: () -> Void
    let onEnterNewAddress: (AddressWidgetType) -> Void
    let onEditExistingAddress: (AddressWidgetType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Profile Auto-fill Section
            if !profileManager.profile.firstName.isEmpty {
                ProfileWelcomeSection(
                    firstName: profileManager.profile.firstName,
                    onUseProfileInfo: onLoadProfileData
                )
            }

            // Contact Information Section
            ContactInformationSection(
                firstName: $viewModel.firstName,
                lastName: $viewModel.lastName,
                email: $viewModel.email,
                phone: $viewModel.phone
            )

            // Shipping Address Section
            ShippingAddressSection(
                viewModel: viewModel,
                profileManager: profileManager,
                onSelectSavedAddress: onSelectSavedAddress,
                onClearShippingAddress: onClearShippingAddress,
                onEnterNewAddress: { onEnterNewAddress(.shipping) },
                onEditExistingAddress: { onEditExistingAddress(.shipping) }
            )

            // Use as billing address toggle
            Toggle("Use as billing address", isOn: $viewModel.useShippingAsBilling)
                .padding(.top, 8)

            // Billing Address Section
            if !viewModel.useShippingAsBilling {
                BillingAddressSection(
                    viewModel: viewModel,
                    profileManager: profileManager,
                    onSelectSavedAddress: onSelectSavedAddress,
                    onClearBillingAddress: onClearBillingAddress,
                    onEnterNewAddress: { onEnterNewAddress(.billing) },
                    onEditExistingAddress: { onEditExistingAddress(.billing) }
                )
            }

            Text("Gift Cards")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            VStack(alignment: .leading, spacing: 16) {
                if cartManager.hasGiftCards {
                    ForEach(cartManager.appliedGiftCards) { appliedGiftCard in
                        GiftCardRowView(appliedGiftCard: appliedGiftCard) {
                            cartManager.removeGiftCard(appliedGiftCard)
                        }
                    }
                } else {
                    Text("No gift cards applied")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                }

                HStack {
                    Button("Add Gift Card") {
                        showingGiftCardEntry = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.defaultPrimary)

                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 16) {
                Text("Order Summary")
                    .font(.title2)
                    .fontWeight(.bold)

                OrderSummaryView(
                    cartManager: cartManager,
                    showShipping: true,
                    showGiftCards: true
                )
            }
        }
        .sheet(isPresented: $showingGiftCardEntry) {
            GiftCardEntryView()
        }
    }
}
