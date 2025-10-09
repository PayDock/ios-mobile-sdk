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
    @Binding var showingAddressWidget: Bool
    @Binding var addressWidgetType: AddressWidgetType

    let onLoadProfileData: () -> Void
    let onSelectSavedAddress: (SavedAddress, AddressWidgetType) -> Void
    let onClearShippingAddress: () -> Void
    let onClearBillingAddress: () -> Void

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
                showingAddressWidget: $showingAddressWidget,
                addressWidgetType: $addressWidgetType,
                onSelectSavedAddress: onSelectSavedAddress,
                onClearShippingAddress: onClearShippingAddress
            )

            // Use as billing address toggle
            Toggle("Use as billing address", isOn: $viewModel.useShippingAsBilling)
                .padding(.top, 8)

            // Billing Address Section
            if !viewModel.useShippingAsBilling {
                BillingAddressSection(
                    viewModel: viewModel,
                    profileManager: profileManager,
                    showingAddressWidget: $showingAddressWidget,
                    addressWidgetType: $addressWidgetType,
                    onSelectSavedAddress: onSelectSavedAddress,
                    onClearBillingAddress: onClearBillingAddress
                )
            }
        }
    }
}
