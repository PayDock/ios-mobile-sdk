//
//  OrderSummaryView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct OrderSummaryView: View {
    @ObservedObject var cartManager: CartManager
    let showShipping: Bool
    let showGiftCards: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Items
            ForEach(cartManager.cartItems) { item in
                HStack {
                    Text("\(item.quantity)x \(item.product.name)")
                        .font(.body)
                    Spacer()
                    Text(item.formattedTotalPrice)
                        .font(.body)
                }
            }

            Divider()

            // Subtotal
            HStack {
                Text("Subtotal")
                    .font(.body)
                Spacer()
                Text(cartManager.formattedSubtotal)
                    .font(.body)
            }

            // Gift Cards
            if showGiftCards && cartManager.hasGiftCards {
                HStack {
                    Text("Gift Cards")
                        .font(.body)
                    Spacer()
                    Text(cartManager.formattedTotalGiftCardAmount)
                        .font(.body)
                        .foregroundColor(.green)
                }
            }

            // Shipping
            if showShipping {
                HStack {
                    Text("Shipping")
                        .font(.body)
                    Spacer()
                    Text(cartManager.formattedShippingCost)
                        .font(.body)
                }
            }

            Divider()

            // Total
            HStack {
                Text("Total")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(cartManager.formattedTotal)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.defaultPrimary)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}
