//
//  PayPalWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PayPalWidgetView: View {

    @StateObject private var viewModel = PayPalWidgetVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalWidget(
                    appearance: getAppearance(),
                    config: viewModel.getConfig()) { onPayPalButtonTap in
                    viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse): viewModel.handleSuccess(charge: chargeResponse)
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        }
    }

    private func getAppearance() -> PayPalWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .paypal,
            isDarkMode: colorScheme == .dark,
            as: PayPalWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? PayPalWidgetAppearance()
    }
}

struct PayPalWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalWidgetView()
    }
}
