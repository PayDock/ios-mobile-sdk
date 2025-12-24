//
//  ProductCardView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 01.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    let cardHeight: CGFloat
    let currentQuantityInCart: Int
    let onAddToCart: () -> Void
    @State private var showingAddedAnimation = false

    // Define fixed heights for consistent layout
    private let imageHeight: CGFloat
    private let titleHeight: CGFloat = 44 // 2 lines at 16pt + spacing
    private let descriptionHeight: CGFloat = 32 // 2 lines at 12pt + spacing
    private let priceHeight: CGFloat = 24 // Single line at 18pt
    private let buttonHeight: CGFloat = 36
    private let padding: CGFloat = 12

    init(product: Product, cardHeight: CGFloat, currentQuantityInCart: Int, onAddToCart: @escaping () -> Void) {
        self.product = product
        self.cardHeight = cardHeight
        self.currentQuantityInCart = currentQuantityInCart
        self.onAddToCart = onAddToCart

        // Calculate image height based on remaining space
        let contentHeight = cardHeight - (padding * 2)
        let fixedContentHeight = titleHeight + descriptionHeight + priceHeight + buttonHeight + (4 * 8) // 8pt spacing between elements
        self.imageHeight = contentHeight - fixedContentHeight
    }

    private var buttonText: String {
        if currentQuantityInCart > 0 {
            return "Add to Cart (\(currentQuantityInCart))"
        } else {
            return "Add to Cart"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Product Image Container - Fixed Height
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: imageHeight)

                // Check if image is SF Symbol or asset image
                if product.imageName.contains(".") || isKnownSFSymbol(product.imageName) {
                    // SF Symbol
                    Image(systemName: product.imageName)
                        .font(.system(size: min(imageHeight * 0.4, 60), weight: .light))
                        .foregroundColor(.defaultPrimary)
                        .frame(maxHeight: imageHeight - 16)
                } else {
                    // Asset Image
                    Image(product.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: imageHeight - 8)
                        .clipped()
                }
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])

            // Product Info Container - Fixed Heights for Each Element
            VStack(alignment: .leading, spacing: 8) {
                // Product Name - Fixed Height Container
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(height: titleHeight, alignment: .top)

                // Product Description - Fixed Height Container
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(height: descriptionHeight, alignment: .top)

                // Price - Fixed Height Container
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.formattedPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.defaultPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: priceHeight, alignment: .center)

                // Add to Cart Button - Fixed Height
                Button(action: {
                    onAddToCart()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        showingAddedAnimation = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingAddedAnimation = false
                    }
                }, label: {
                    HStack(spacing: 6) {
                        Image(systemName: showingAddedAnimation ? "checkmark" : "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text(showingAddedAnimation ? "Added!" : buttonText)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(showingAddedAnimation ? Color.green : Color.defaultPrimary)
                    .cornerRadius(8)
                })
                .accessibilityIdentifier("Add to Cart \(product.name)")
                .disabled(showingAddedAnimation)
            }
            .padding(padding)
        }
        .frame(height: cardHeight)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    // Helper function to detect common SF Symbols that don't contain dots
    private func isKnownSFSymbol(_ imageName: String) -> Bool {
        let knownSFSymbols = [
            "jacket", "sweater", "pants", "hoodie", "shorts", "coat",
            "scarf", "belt"
        ]
        return knownSFSymbols.contains(imageName)
    }
}
