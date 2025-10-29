//
//  CartView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CartView: View {
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckout = false
    @State private var showingGiftCardEntry = false

    var body: some View {
        NavigationView {
            Group {
                if cartManager.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCheckout) {
                EnhancedCheckoutView(onDismissParent: {
                    // Dismiss the CartView when checkout is successful
                    dismiss()
                })
            }
            .sheet(isPresented: $showingGiftCardEntry) {
                GiftCardEntryView()
            }
        }
    }

    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.medium)

            Text("Add some products to get started")
                .font(.body)
                .foregroundColor(.gray)

            Button("Continue Shopping") {
                dismiss()
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .frame(height: 44)
            .frame(maxWidth: 200)
            .background(Color.defaultPrimary)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private var cartContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // Cart Items
                    cartItemsSection

                    // Gift Card Section
                    giftCardSection

                    // Shipping Options
                    shippingSection

                    // Order Summary
                    orderSummarySection
                }
                .padding()
            }

            // Checkout Button
            checkoutButton
        }
        .background(Color(.systemBackground))
    }

    private var cartItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items (\(cartManager.itemCount))")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(cartManager.cartItems) { cartItem in
                CartItemRowView(cartItem: cartItem) { updatedItem, newQuantity in
                    cartManager.updateQuantity(for: updatedItem, quantity: newQuantity)
                } onRemove: { itemToRemove in
                    cartManager.removeFromCart(cartItem: itemToRemove)
                }
            }
        }
    }

    private var giftCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Gift Cards")
                    .font(.headline)

                Spacer()

                Button("Add Gift Card") {
                    showingGiftCardEntry = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.defaultPrimary)
            }

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
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var shippingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shipping Options")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(CartShippingOption.allCases, id: \.self) { option in
                ShippingOptionRow(
                    option: option,
                    isSelected: cartManager.selectedShipping == option
                ) {
                    cartManager.selectedShipping = option
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private var orderSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Subtotal")
                    .font(.body)
                Spacer()
                Text(cartManager.formattedSubtotal)
                    .font(.body)
            }

            if cartManager.hasGiftCards {
                HStack {
                    Text("Gift Cards")
                        .font(.body)
                    Spacer()
                    Text(cartManager.formattedTotalGiftCardAmount)
                        .font(.body)
                        .foregroundColor(.green)
                }
            }

            HStack {
                Text("Shipping")
                    .font(.body)
                Spacer()
                Text(cartManager.formattedShippingCost)
                    .font(.body)
            }

            Divider()

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

    private var checkoutButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button("Proceed to Checkout") {
                showingCheckout = true
            }
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .semibold))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.defaultPrimary)
            .cornerRadius(8)
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
