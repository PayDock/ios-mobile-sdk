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
            // Recommended: Wrap in ScrollViewReader for scroll-to-error support
            // This enables VoiceOver to scroll to error fields when using large text sizes
            ScrollViewReader { proxy in
                ScrollView {
                    // Card Details Widget
                    CardDetailsWidget(
                        config: viewModel.getConfig(),
                        appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                        eventDelegate: viewModel,
                        onScrollToField: { field in
                            // Handle scroll request from widget
                            withAnimation {
                                proxy.scrollTo(field, anchor: .center)
                            }
                        },
                        completion: { result in
                            switch result {
                            case .success(let cardResult):
                                viewModel.handleSuccess(cardResult)
                            case .failure(let error):
                                viewModel.handleError(error)
                            }
                        })
                }
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
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
