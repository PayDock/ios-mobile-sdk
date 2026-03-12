//
//  ProductListView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 01.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var products: [Product] = []
    @State private var selectedCategory: ProductCategory?
    @State private var showingCart = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Fixed card height for consistent appearance
    private let cardHeight: CGFloat = 280

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Category Filter
                    categoryFilter

                    // Products Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProducts) { product in
                            ProductCardView(
                                product: product,
                                cardHeight: cardHeight,
                                currentQuantityInCart: cartManager.getQuantity(for: product)
                            ) {
                                cartManager.addToCart(product: product)
                            }
                            .accessibilityIdentifier("Product Card \(product.name)")
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("demoLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCart = true
                    } label: {
                        ZStack {
                            Image(systemName: "cart")
                                .font(.system(size: 20))
                            if cartManager.itemCount > 0 {
                                Text("\(cartManager.itemCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -10)
                            }
                        }
                    }
                    .accessibilityIdentifier("Cart Button")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 20))
                    }
                    .accessibilityIdentifier("Profile Button")
                }
            }
            .sheet(isPresented: $showingCart) {
                CartView()
            }
        }
        .onAppear {
            loadProducts()
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                .accessibilityIdentifier("Category Filter All")

                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                    .accessibilityIdentifier("Category Filter \(category.displayName)")
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var filteredProducts: [Product] {
        if let selectedCategory = selectedCategory {
            return products.filter { $0.category == selectedCategory }
        }
        return products
    }

    private func loadProducts() {
        products = ProductService.shared.getAllProducts()
    }
}
