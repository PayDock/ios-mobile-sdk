//
//  SavedAddressSelectionView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct SavedAddressSelectionView: View {
    let address: SavedAddress
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .defaultPrimary : .gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(address.label)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Text(address.formattedAddress.replacingOccurrences(of: "\n", with: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if address.isDefault {
                    Text("DEFAULT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("Save address selection")
    }
}
