//
//  CartItemRowView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CartItemRowView: View {
    let cartItem: CartItem
    let onQuantityChange: (CartItem, Int) -> Void
    let onRemove: (CartItem) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            Image(cartItem.product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.product.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)

                Text(cartItem.product.formattedPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text(cartItem.formattedTotalPrice)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.defaultPrimary)
            }

            Spacer()

            // Quantity Controls
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button {
                        let newQuantity = max(0, cartItem.quantity - 1)
                        onQuantityChange(cartItem, newQuantity)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(cartItem.quantity > 1 ? .defaultPrimary : .gray)
                    }
                    .disabled(cartItem.quantity <= 1)

                    Text("\(cartItem.quantity)")
                        .font(.system(size: 16, weight: .medium))
                        .frame(minWidth: 20)

                    Button {
                        onQuantityChange(cartItem, cartItem.quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.defaultPrimary)
                    }
                }

                Button {
                    onRemove(cartItem)
                } label: {
                    Text("Remove")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}
