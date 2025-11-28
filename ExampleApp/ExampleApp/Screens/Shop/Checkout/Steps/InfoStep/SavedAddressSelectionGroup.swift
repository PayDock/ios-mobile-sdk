//
//  SavedAddressSelectionGroup.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct SavedAddressSelectionGroup: View {
    let addresses: [SavedAddress]
    let selectedAddressId: String?
    let onSelectAddress: (SavedAddress) -> Void
    let onEnterNewAddress: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select saved address or enter new one:")
                .font(.subheadline)
                .foregroundColor(.gray)

            ForEach(addresses) { address in
                SavedAddressSelectionView(
                    address: address,
                    isSelected: selectedAddressId == address.id
                ) {
                    onSelectAddress(address)
                }
            }

            Button("Enter new address") {
                onEnterNewAddress()
            }
            .font(.system(size: 14))
            .foregroundColor(.defaultPrimary)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(8)
    }
}
