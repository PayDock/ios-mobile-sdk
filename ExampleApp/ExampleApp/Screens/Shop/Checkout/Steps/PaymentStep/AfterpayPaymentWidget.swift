//
//  AfterpayPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AfterpayPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        AfterpayWidget(
            viewState: viewModel.viewState,
            configuration: viewModel.getAfterpayConfig(),
            loadingDelegate: viewModel,
            tokenRequest: { tokenResult in
                viewModel.initializeAfterpayCharge(completion: tokenResult)
            },
            selectAddress: { _, provideShippingOptions in
                provideShippingOptions(viewModel.getAfterpayShippingOptions())
            },
            selectShippingOption: { _, _ in

            }, completion: { result in
                viewModel.handleAfterpayResult(result)
            })
        .frame(height: 50)
    }
}
