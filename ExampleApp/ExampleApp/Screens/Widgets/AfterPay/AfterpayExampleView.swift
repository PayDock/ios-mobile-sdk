//
//  AfterpayExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct AfterpayExampleView: View {

    @StateObject private var viewModel = AfterpayExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                AfterpayWidget(
                    configuration: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
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
}

struct AfterpayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayExampleView()
    }
}
