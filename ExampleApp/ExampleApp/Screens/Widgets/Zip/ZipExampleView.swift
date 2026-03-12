//
//  ZipExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct ZipExampleView: View {

    @StateObject private var viewModel = ZipExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                ZipWidget(
                    config: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                    completion: { result in
                        switch result {
                        case .success(let ottToken): viewModel.handleSuccess(ottToken: ottToken)
                        case .failure(let error): viewModel.handleError(error: error)
                        }
                    }
                )
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle,
                   isPresented: $viewModel.showAlert,
                   actions: {}, message: {
                Text(viewModel.alertMessage)
            })
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        }
    }
}

struct ZipWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ZipExampleView()
    }
}
