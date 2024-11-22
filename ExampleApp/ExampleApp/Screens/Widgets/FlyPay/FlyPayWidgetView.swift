//
//  FlyPayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 11.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct FlyPayWidgetView: View {

    @StateObject private var viewModel = FlyPayWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                FlyPayWidget(clientId: ProjectEnvironment.shared.getFlyPayClientId() ?? "") { onFlyPayButtonTap in
                    viewModel.initializeWalletCharge(completion: onFlyPayButtonTap)
                } completion: { result in
                    switch result {
                    case .success: viewModel.handleSuccess()
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
                .frame(height: 48)
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct FlyPayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        FlyPayWidgetView()
    }
}
