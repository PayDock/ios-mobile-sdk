//
//  ColesPayPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ColesPayPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        ColesPayWidget(
            viewState: viewModel.viewState,
            loadingDelegate: viewModel,
            config: .init(clientId: ProjectEnvironment.shared.getColesPayClientId() ?? "")
        ) { tokenResult in
            viewModel.initializeWalletChargeColesPay(completion: tokenResult)
        } completion: { result in
            switch result {
            case .success:
                currentStep = .review
            case .failure: break
            }
        }
        .frame(height: 50)
    }
}
