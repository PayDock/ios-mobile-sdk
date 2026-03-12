//
//  PaymentMethodRow.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .defaultPrimary : .gray)

                Image(method.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 24)

                Text(method.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(8)
        }
        .accessibilityIdentifier(method.displayName)
    }
}
