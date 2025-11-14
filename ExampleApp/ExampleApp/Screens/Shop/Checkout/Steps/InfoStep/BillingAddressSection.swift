//
//  BillingAddressSection.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct BillingAddressSection: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @ObservedObject var profileManager: UserProfileManager

    let onSelectSavedAddress: (SavedAddress, AddressWidgetType) -> Void
    let onClearBillingAddress: () -> Void
    let onEnterNewAddress: () -> Void
    let onEditExistingAddress: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Billing Address")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // Saved Address Selection for Billing
            if !profileManager.profile.savedAddresses.isEmpty {
                SavedAddressSelectionGroup(
                    addresses: profileManager.profile.savedAddresses,
                    selectedAddressId: viewModel.selectedBillingAddressId,
                    onSelectAddress: { address in
                        onSelectSavedAddress(address, .billing)
                    },
                    onEnterNewAddress: {
                        // Open address input directly without deselecting current address
                        onEnterNewAddress()
                    }
                )
            }

            // Billing Address Fields or Widget Button
            if viewModel.selectedBillingAddressId == nil {
                AddressInputSection(
                    isAddressComplete: viewModel.billingAddressComplete,
                    formattedAddress: viewModel.formattedBillingAddress,
                    addressType: "Billing",
                    onEnterAddress: {
                        if viewModel.billingAddressComplete {
                            onEditExistingAddress()
                        } else {
                            onEnterNewAddress()
                        }
                    }
                )
            }
        }
    }
}
