//
//  MastercardPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct MastercardPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        VStack {
            Button("Checkout with Click to Pay") {
                viewModel.showMastercardWebView = true
            }
            .foregroundStyle(.white)
            .font(Font.system(size: 16, weight: .semibold))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.defaultPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding()
        }
        .sheet(isPresented: $viewModel.showMastercardWebView) {
            NavigationStack {
                VStack {
                    ClickToPayWidget(
                        config: .init(
                            serviceId: ProjectEnvironment.shared.getClickToPayServiceId() ?? "",
                            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                            meta: nil
                        )
                    ) { result in
                        viewModel.handleClickToPayResult(result)
                    }
                }
                .navigationTitle("Checkout with Click to Pay")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
