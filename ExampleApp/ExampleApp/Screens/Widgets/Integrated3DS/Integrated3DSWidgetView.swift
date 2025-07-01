//
//  Integrated3DSWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023.
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct Integrated3DSWidgetView: View {

    @StateObject private var viewModel = Integrated3DSVM()
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
                        }) {
                            NavigationStack {
                                VStack {
                                    Integrated3DSWidget(
                                        config: .init(token: viewModel.token3DS),
                                        appearance: getAppearance(),
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
                        }
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
    
    private func getAppearance() -> ThreeDSWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(for: .integrated3ds, isDarkMode: colorScheme == .dark, as: ThreeDSWidgetAppearance.self, shouldCreateDefaultIfNeeded: false)
        return appearance ?? ThreeDSWidgetAppearance()
    }
}

struct Integrated3DSWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Integrated3DSWidgetView()
    }
}
