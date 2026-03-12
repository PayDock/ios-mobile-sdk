//
//  PaymentMethodSelectionView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PaymentMethodSelectionView: View {
    let selectedMethod: PaymentMethod?
    let onMethodSelected: (PaymentMethod) -> Void
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        VStack(spacing: 12) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                VStack(alignment: .leading, spacing: 8) {
                    PaymentMethodRow(
                        method: method,
                        isSelected: selectedMethod == method
                    ) {
//                        withAnimation(.easeInOut) {
                            onMethodSelected(method)
//                        }
                    }

                    if selectedMethod == method {
                        PaymentWidgetView(
                            method: method,
                            viewModel: viewModel,
                            currentStep: $currentStep
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .animation(.easeInOut, value: selectedMethod)
    }
}
