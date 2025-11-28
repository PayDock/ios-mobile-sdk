//
//  AfterpayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.02.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AfterpayWidgetView: View {

    @StateObject private var viewModel = AfterpayWidgetVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                AfterpayWidget(
                    configuration: viewModel.getAfterpayConfig(),
                    appearance: getAppearance(),
                    eventDelegate: viewModel,
                    tokenRequest: { tokenResult in
                        viewModel.initializeWalletCharge(completion: tokenResult)
                    }, selectAddress: { _, provideShippingOptions in
                        provideShippingOptions(viewModel.getShippingOptions())
                    }, selectShippingOption: { _, provideShippingOptionUpdateResult in
                        provideShippingOptionUpdateResult(viewModel.getShippingOptionUpdate())
                    }, completion: { result in
                        switch result {
                        case .success(let chargeData):
                            viewModel.handleSuccess(chargeData)
                        case .failure(let error): viewModel.handleError(error: error)
                        }
                    })
                    .frame(height: 50)
                    .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }

    private func getAppearance() -> AfterpayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .afterPay,
            isDarkMode: colorScheme == .dark,
            as: AfterpayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? AfterpayWidgetAppearance()
    }
}

struct AfterpayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayWidgetView()
    }
}
