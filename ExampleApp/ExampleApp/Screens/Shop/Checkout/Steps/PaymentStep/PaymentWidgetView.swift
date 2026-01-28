//
//  PaymentWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PaymentWidgetView: View {
    let method: PaymentMethod
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        switch method {
        case .card:
            CardPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .applePay:
            ApplePayPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .payPal:
            PayPalPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .afterpay:
            AfterpayPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .mastercard:
            MastercardPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .colesPay:
            ColesPayPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        case .zip:
            ZipPaymentWidget(viewModel: viewModel, currentStep: $currentStep)
        }
    }
}
