//
//  CardDetailsExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct CardDetailsExampleView: View {
    @StateObject var viewModel = CardDetailsExampleVM()
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var configManager = ConfigManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                CardDetailsWidget(
                    config: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                    eventDelegate: viewModel,
                    completion: { result in
                        switch result {
                        case .success(let cardResult):
                            viewModel.handleSuccess(cardResult)
                        case .failure(let error):
                            viewModel.handleError(error)
                        }
                    })
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsExampleView()
    }
}
