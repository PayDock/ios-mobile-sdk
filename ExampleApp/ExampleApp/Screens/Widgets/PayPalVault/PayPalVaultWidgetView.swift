//
//  PayPalVaultWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 14.10.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PayPalVaultWidgetView: View {
    
    @StateObject private var viewModel = PayPalVaultWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalSavePaymentSourceWidget(config: viewModel.getConfig()) { result in
                    switch result {
                    case let .success(payPalVaultResult):
                        viewModel.handleSuccess(result: payPalVaultResult)
                    case let .failure(error):
                        viewModel.handleError(error: error)
                    }
                }
                .frame(height: 48)
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
        PayPalVaultWidgetView()
    }
}
