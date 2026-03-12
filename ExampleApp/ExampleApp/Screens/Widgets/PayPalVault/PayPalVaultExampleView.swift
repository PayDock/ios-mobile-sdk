//
//  PayPalVaultExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct PayPalVaultExampleView: View {

    @StateObject private var viewModel = PayPalVaultExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalSavePaymentSourceWidget(
                    config: viewModel.getConfig(),
                    eventDelegate: viewModel,
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark)
                ) { result in
                        switch result {
                        case let .success(payPalVaultResult):
                            viewModel.handleSuccess(result: payPalVaultResult)
                        case let .failure(error):
                            viewModel.handleError(error: error)
                        }
                    }
                .padding()
            }
            .background(.white)
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        }
    }
}

struct PayPalVaultWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalVaultExampleView()
    }
}
