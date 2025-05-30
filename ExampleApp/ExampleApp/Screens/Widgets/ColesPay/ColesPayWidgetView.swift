//
//  ColesPayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 11.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ColesPayWidgetView: View {
    
    @StateObject private var viewModel = ColesPayWidgetVM()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ColesPayWidget(clientId: ProjectEnvironment.shared.getColesPayClientId() ?? "") { onColesPayButtonTap in
                    viewModel.initializeWalletCharge(completion: onColesPayButtonTap)
                } completion: { result in
                    switch result {
                    case .success: viewModel.handleSuccess()
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle,
                   isPresented: $viewModel.showAlert,
                   actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct ColesPayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ColesPayWidgetView()
    }
}
