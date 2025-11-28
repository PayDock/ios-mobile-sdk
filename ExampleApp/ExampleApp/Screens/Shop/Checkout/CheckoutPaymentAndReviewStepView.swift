//
//  CheckoutPaymentAndReviewStepView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 13.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CheckoutPaymentAndReviewStepView: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @ObservedObject var cartManager: CartManager
    @Binding var currentStep: CheckoutStep

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Payment Method Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Payment Method")
                    .font(.title2)
                    .fontWeight(.bold)

                // Payment Method Selection
                PaymentMethodSelectionView(
                    selectedMethod: viewModel.selectedPaymentMethod,
                    onMethodSelected: { method in
                        viewModel.selectedPaymentMethod = method
                    },
                    viewModel: viewModel,
                    currentStep: $currentStep
                )
            }
        }
    }
}
