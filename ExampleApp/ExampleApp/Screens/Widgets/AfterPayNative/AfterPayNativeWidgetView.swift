//
//  AfterPayNativeWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 22.02.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AfterPayNativeWidgetView: View {

    @StateObject private var viewModel = AfterPayNativeWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                AfterPayNativeWidget { onAfterPayButtonTap in
                    viewModel.initializeWalletCharge(completion: onAfterPayButtonTap)
                } completion: { result in
                    switch result {
                    case .success: viewModel.handleSuccess()
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

struct AfterPayNativeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayNativeWidgetView()
    }
}
