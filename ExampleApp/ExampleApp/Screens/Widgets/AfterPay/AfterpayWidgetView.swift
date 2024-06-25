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

    var body: some View {
        NavigationStack {
            ScrollView {
                AfterpayWidget(
                    configuration: viewModel.getAfterpayConfig(),
                    afterPayToken: { onAfterpayButtonTap in
                        viewModel.initializeWalletCharge(completion: onAfterpayButtonTap)
                    }, selectAddress: { address, provideShippingOptions in
                        provideShippingOptions(viewModel.getShippingOptions())
                    }, selectShippingOption: { shippingOption, provideShippingOptionUpdateResult in
                        provideShippingOptionUpdateResult(viewModel.getShippingOptionUpdate())
                    },
                    buttonWidth: 360.0) { result in
                    switch result {
                    case .success(let chargeData): 
                        viewModel.handleSuccess(chargeData)
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
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
        AfterpayWidgetView()
    }
}
