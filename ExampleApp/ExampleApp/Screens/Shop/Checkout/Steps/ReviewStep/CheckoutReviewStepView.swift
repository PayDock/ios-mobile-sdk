//
//  CheckoutReviewStepView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct CheckoutReviewStepView: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @ObservedObject var cartManager: CartManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Review")
                .font(.title2)
                .fontWeight(.bold)

            // Order Summary
            OrderSummaryView(
                cartManager: cartManager,
                showShipping: true,
                showGiftCards: true
            )

            // Shipping Information
            ShippingInformationCard(viewModel: viewModel)

            // Payment Information
            PaymentInformationCard(viewModel: viewModel)
        }
    }
}
