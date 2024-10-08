//
//  MastercardWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ClickToPayWidgetView: View {

    @StateObject private var viewModel = ClickToPayWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                    EmptyView()
                        .sheet(isPresented: $viewModel.showWebView, content: {
                            NavigationStack {
                                VStack {
                                    ClickToPayWidget(
                                        serviceId: ProjectEnvironment.shared.getMastercardServiceId() ?? "",
                                        accessToken: ProjectEnvironment.shared.getAccessToken(),
                                        meta: nil,
                                        completion: { result in
                                            switch result {
                                            case .success(let result):
                                                viewModel.handleMastercardResult(result)
                                                
                                            case .failure(let error):
                                                viewModel.alertMessage = error.localizedDescription
                                                viewModel.showAlert = true
                                            }
                                        })
                                    .navigationTitle("Checkout with Click to Pay")
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        })
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: { }, message: {
            Text(viewModel.alertMessage)
        })
    }
}

struct ClickToPayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ClickToPayWidgetView()
    }
}
