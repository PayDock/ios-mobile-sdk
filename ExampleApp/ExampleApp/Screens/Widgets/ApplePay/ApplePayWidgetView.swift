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

    var body: some View {
        NavigationStack {
            ScrollView {
                ApplePayWidget { onApplePayButtonTap in
                    viewModel.initializeWalletCharge(completion: onApplePayButtonTap)
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
        }
    }
}

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
