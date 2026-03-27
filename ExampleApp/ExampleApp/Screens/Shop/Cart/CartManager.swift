//
//  CartManager.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import Combine

class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published var cartItems: [CartItem] = []
    @Published var selectedShipping: CartShippingOption = .standard
    @Published var appliedGiftCards: [AppliedGiftCard] = []

    private init() {}

    // MARK: - Cart Operations

    func addToCart(product: Product, quantity: Int = 1) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[existingItemIndex] = CartItem(
                product: product,
                quantity: cartItems[existingItemIndex].quantity + quantity
            )
        } else {
            cartItems.append(CartItem(product: product, quantity: quantity))
        }
    }

    func removeFromCart(cartItem: CartItem) {
        cartItems.removeAll { $0.id == cartItem.id }
    }

    func updateQuantity(for cartItem: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            } else {
                cartItems[index] = CartItem(product: cartItem.product, quantity: quantity)
            }
        }
    }

    func clearCart() {
        cartItems.removeAll()
        appliedGiftCards.removeAll()
    }

    func getQuantity(for product: Product) -> Int {
        return cartItems.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    // MARK: - Gift Card Operations

    func applyGiftCard(_ giftCard: GiftCard) -> Bool {
        // Check if gift card is already applied
        if appliedGiftCards.contains(where: { $0.giftCard.id == giftCard.id }) {
            return false
        }

        // Calculate how much we can apply from this gift card
        let remainingTotal = totalAfterGiftCards
        let applicableAmount = min(giftCard.balance, remainingTotal)

        if applicableAmount > 0 {
            let appliedCard = AppliedGiftCard(
                giftCard: giftCard,
                appliedAmount: applicableAmount
            )
            appliedGiftCards.append(appliedCard)
            return true
        }

        return false
    }

    func removeGiftCard(_ appliedGiftCard: AppliedGiftCard) {
        appliedGiftCards.removeAll { $0.id == appliedGiftCard.id }
    }

    func removeAllGiftCards() {
        appliedGiftCards.removeAll()
    }

    // MARK: - Calculations

    var itemCount: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }

    var shippingCost: Double {
        // Free shipping if total (after gift cards) is above certain threshold or if everything is covered by gift cards
        let remaining = totalAfterGiftCards
        return remaining > 0 ? selectedShipping.price : 0.0
    }

    var totalGiftCardAmount: Double {
        return appliedGiftCards.reduce(0) { $0 + $1.appliedAmount }
    }

    var totalAfterGiftCards: Double {
        return max(0, subtotal - totalGiftCardAmount)
    }

    var total: Double {
        return totalAfterGiftCards + shippingCost
    }

    var formattedSubtotal: String {
        return String(format: "$%.2f", subtotal)
    }

    var formattedShippingCost: String {
        return shippingCost == 0 ? "Free" : String(format: "$%.2f", shippingCost)
    }

    var formattedTotalGiftCardAmount: String {
        return String(format: "-$%.2f", totalGiftCardAmount)
    }

    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }

    var stringTotal: String {
        return String(format: "%.2f", total)
    }

    var stringTotalWithoutShipping: String {
        return String(format: "%.2f", (total - shippingCost))
    }

    var stringShippingCost: String {
        return String(format: "%.2f", shippingCost)
    }

    var isEmpty: Bool {
        return cartItems.isEmpty
    }

    var hasGiftCards: Bool {
        return !appliedGiftCards.isEmpty
    }

    // MARK: - Gift Card Validation

    func validateGiftCard(cardNumber: String, pin: String) -> GiftCard? {
        // Simulate gift card validation
        // In a real app, this would make an API call

        let sampleGiftCards = [
            GiftCard(cardNumber: "1234567890123456", pin: "1234", balance: 50.0),
            GiftCard(cardNumber: "9876543210987654", pin: "5678", balance: 100.0),
            GiftCard(cardNumber: "1111222233334444", pin: "9999", balance: 25.0)
        ]

        return sampleGiftCards.first { $0.cardNumber == cardNumber && $0.pin == pin }
    }
}
