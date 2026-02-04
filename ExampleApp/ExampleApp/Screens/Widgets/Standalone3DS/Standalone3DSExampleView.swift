//
//  Standalone3DSExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI
import MobileSDK

struct Standalone3DSExampleView: View {

    @StateObject private var viewModel = Standalone3DSExampleVM()
    @State var isSheetPresented = false
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
                        }, content: {
                            NavigationStack {
                                VStack {
                                    Standalone3DSWidget(
                                        config: ThreeDSConfig(token: viewModel.token3DS),
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
            viewModel.getVaultToken()
        }
    }
}

struct Standalone3DSWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Standalone3DSExampleView()
    }
}
