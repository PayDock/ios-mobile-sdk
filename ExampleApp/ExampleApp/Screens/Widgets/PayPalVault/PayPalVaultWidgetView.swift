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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalSavePaymentSourceWidget(
                    config: viewModel.getConfig(),
                    appearance: getAppearance()) { result in
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
    
    private func getAppearance() -> PayPalVaultAppearance {
        let appearance = StyleThemeManager.getAppearance(for: .paypalVault, isDarkMode: colorScheme == .dark, as: PayPalVaultAppearance.self, shouldCreateDefaultIfNeeded: false)
        return appearance ?? PayPalVaultAppearance()
    }
}

struct PayPalVaultWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalVaultWidgetView()
    }
}
