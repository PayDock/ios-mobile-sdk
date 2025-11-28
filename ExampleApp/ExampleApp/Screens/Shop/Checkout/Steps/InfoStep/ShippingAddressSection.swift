//
//  ShippingAddressSection.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ShippingAddressSection: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @ObservedObject var profileManager: UserProfileManager

    let onSelectSavedAddress: (SavedAddress, AddressWidgetType) -> Void
    let onClearShippingAddress: () -> Void
    let onEnterNewAddress: () -> Void
    let onEditExistingAddress: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shipping Address")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // Saved Address Selection
            if !profileManager.profile.savedAddresses.isEmpty {
                SavedAddressSelectionGroup(
                    addresses: profileManager.profile.savedAddresses,
                    selectedAddressId: viewModel.selectedShippingAddressId,
                    onSelectAddress: { address in
                        onSelectSavedAddress(address, .shipping)
                    },
                    onEnterNewAddress: {
                        // Open address input directly without deselecting current address
                        onEnterNewAddress()
                    }
                )
            }

            // Address Fields or Widget Button
            if viewModel.selectedShippingAddressId == nil {
                AddressInputSection(
                    isAddressComplete: viewModel.shippingAddressComplete,
                    formattedAddress: viewModel.formattedShippingAddress,
                    addressType: "Shipping",
                    onEnterAddress: {
                        if viewModel.shippingAddressComplete {
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
