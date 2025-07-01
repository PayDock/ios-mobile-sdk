//
//  Standalone3DSWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 29.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct Standalone3DSWidgetView: View {

    @StateObject private var viewModel = Standalone3DSVM()
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
                        }) {
                            NavigationStack {
                                VStack {
                                    Standalone3DSWidget(
                                        config: ThreeDSConfig(token: viewModel.token3DS),
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
            viewModel.getValutToken()
        }
    }
    
    private func getAppearance() -> ThreeDSWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(for: .standalone3ds, isDarkMode: colorScheme == .dark, as: ThreeDSWidgetAppearance.self, shouldCreateDefaultIfNeeded: false)
        return appearance ?? ThreeDSWidgetAppearance()
    }
}

struct Standalone3DSWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Standalone3DSWidgetView()
    }
}
