//
//  CheckoutPaymentStepView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CheckoutPaymentStepView: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.title2)
                .fontWeight(.bold)

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
