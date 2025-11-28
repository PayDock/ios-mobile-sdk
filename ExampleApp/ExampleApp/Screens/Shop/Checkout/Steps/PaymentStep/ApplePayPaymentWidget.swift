//
//  ApplePayPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ApplePayPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        ApplePayWidget { onApplePayButtonTap in
            viewModel.initializeApplePayCharge(completion: onApplePayButtonTap)
        } completion: { result in
            viewModel.handleApplePayResult(result)
        }
        .frame(height: 50)
    }
}
