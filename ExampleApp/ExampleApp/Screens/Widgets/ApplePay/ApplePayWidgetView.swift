//
//  ApplePayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 04.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ApplePayWidgetView: View {

    @StateObject private var viewModel = ApplePayWidgetVM()
    @State var isSheetPresented = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                ApplePayWidget(appearance: getAppearance()) { onApplePayButtonTap in
                    viewModel.initializeWalletCharge(completion: onApplePayButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse): viewModel.handleSuccess(charge: chargeResponse)
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
                .frame(height: 50)
                .padding()
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }

    private func getAppearance() -> ApplePayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .applePay,
            isDarkMode: colorScheme == .dark,
            as: ApplePayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ApplePayWidgetAppearance()
    }
}

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
