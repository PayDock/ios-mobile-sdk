//
//  AfterPayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.02.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AfterPayWidgetView: View {

    @StateObject private var viewModel = AfterPayWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                AfterPayWidget(afterPayToken: { onAfterPayButtonTap in
                    viewModel.initializeWalletCharge(completion: onAfterPayButtonTap)
                }, buttonWidth: 360.0) { result in
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

struct AfterPayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayWidgetView()
    }
}
