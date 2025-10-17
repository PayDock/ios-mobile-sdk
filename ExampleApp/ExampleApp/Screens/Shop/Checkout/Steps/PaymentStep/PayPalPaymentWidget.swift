//
//  PayPalPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PayPalPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        PayPalWidget(
            viewState: viewModel.viewState,
            config: .init(
                accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? ""),
            loadingDelegate: viewModel) { onPayPalButtonTap in
                viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
            } completion: { result in
                viewModel.handlePayPalResult(result)
            }
            .frame(height: 48.0)
    }
}
