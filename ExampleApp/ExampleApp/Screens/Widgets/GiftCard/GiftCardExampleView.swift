//
//  GiftCardExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct GiftCardExampleView: View {

    @StateObject var viewModel = GiftCardExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget(
                    config: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                    eventDelegate: viewModel) { result in
                        switch result {
                        case .success(let giftCardResult):
                            viewModel.handleSuccess(giftCardResult)
                        case .failure(let error):
                            viewModel.handleError(error)
                        }
                    }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardExampleView()
    }
}
