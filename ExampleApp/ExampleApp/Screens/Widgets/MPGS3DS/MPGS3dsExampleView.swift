//
//  MPGS3dsExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import SwiftUI
import MobileSDK

struct MPGS3dsExampleView: View {

    @StateObject private var viewModel = MPGS3dsExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                        .sheet(isPresented: $viewModel.showWebView, onDismiss: {
                            if !viewModel.alertMessage.isEmpty {
                                viewModel.showAlert = true
                            }
                            viewModel.isLoading = false
                        }, content: {
                            NavigationStack {
                                VStack {
                                    MPGS3DSWidget(
                                        config: .init(token: viewModel.token3DS),
                                        appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                                        completion: { result in
                                            switch result {
                                            case .success(let result):
                                                viewModel.handle3dsEvent(result)

                                            case .failure(let error):
                                                viewModel.handleFailure(error: error)
                                            }
                                        })
                                    .navigationTitle("3DS Check")
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        })
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    Spacer()
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .alert("3DS", isPresented: $viewModel.showAlert, actions: {}, message: {
            Text(viewModel.alertMessage)
        })
        .onAppear {
            viewModel.tokeniseCardDetails()
        }
    }
}

struct MPGS3dsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MPGS3dsExampleView()
    }
}
