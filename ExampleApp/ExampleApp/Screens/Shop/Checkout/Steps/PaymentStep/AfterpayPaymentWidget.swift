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
            configuration: viewModel.getAfterpayConfig(),
            tokenRequest: { tokenResult in
                viewModel.initializeAfterpayCharge(completion: tokenResult)
            },
            selectAddress: { _, _ in
                // Provide shipping options based on user selected address if needed
                // Check AfterpayWidget example for more details
                // provideShippingOptions(viewModel.getShippingOptions())
            },
            selectShippingOption: { _, _ in
                // Provide shipping update if needed based on the selected shipping option
                // Check AfterpayWidget example for more details
                // provideShippingOptionUpdateResult(viewModel.getShippingOptionUpdate())
            }, completion: { result in
                switch result {
                case .success:
                    currentStep = .review
                case .failure: break
                }
            })
            .frame(height: 50)
    }
}
