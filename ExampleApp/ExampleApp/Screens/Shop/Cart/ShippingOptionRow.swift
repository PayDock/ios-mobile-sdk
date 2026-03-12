//
//  ShippingOptionRow.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ShippingOptionRow: View {
    let option: CartShippingOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .defaultPrimary : .gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Text(option.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(option.formattedPrice)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("Shipping Option \(option.name)")
    }
}
