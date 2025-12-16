//
//  ZipExampleView.swift
//  ExampleApp
//
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI
import MobileSDK

struct ZipExampleView: View {

    @StateObject private var viewModel = ZipExampleVM()
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedStyle: ZipButtonStyle = .whiteOnBlack

    var body: some View {
        NavigationStack {
            ScrollView {
                ZipWidget(
                    config: viewModel.createZipConfig(),
                    appearance: getAppearance(),
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

    private func getAppearance() -> ZipWidgetAppearance {
        return ZipWidgetAppearance(
            buttonStyle: selectedStyle
        )
    }
}

struct ZipWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ZipExampleView()
    }
}
