//
//  ApplePayPaymentWidget.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import SwiftUI
import MobileSDK

struct ApplePayPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        ApplePayWidget(
            config: viewModel.applePayConfig,
            onShippingContactSelected: { contact in
                viewModel.handleApplePayShippingContactSelected(contact)
            },
            onShippingMethodSelected: { method in
                viewModel.handleApplePayShippingMethodSelected(method)
            },
            completion: { result in
                viewModel.handleApplePayResult(result)
            }
        )
        .frame(height: 50)
    }
}
