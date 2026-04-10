//
//  ApplePayExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK
import PassKit

struct ApplePayExampleView: View {

    @StateObject private var viewModel = ApplePayExampleVM()
    @State var isSheetPresented = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                ApplePayWidget(
                    config: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                    eventDelegate: viewModel,
                    completion: { result in
                        switch result {
                        case .success(let data): viewModel.handleSuccess(data: data)
                        case .failure(let error): viewModel.handleError(error: error)
                        }
                    }
                )
                .frame(height: 50)
                .padding()
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayExampleView()
    }
}
