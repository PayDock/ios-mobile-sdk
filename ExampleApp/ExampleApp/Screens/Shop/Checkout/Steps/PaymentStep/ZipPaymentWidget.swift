//
//  ZipPaymentWidget.swift
//  ExampleApp
//
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI
import MobileSDK

struct ZipPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        ZipWidget(
            viewState: viewModel.viewState,
            config: viewModel.getZipConfig(),
            loadingDelegate: viewModel,
            completion: { result in
                viewModel.handleZipResult(result)
            }
        )
        .frame(height: 50)
    }
}
