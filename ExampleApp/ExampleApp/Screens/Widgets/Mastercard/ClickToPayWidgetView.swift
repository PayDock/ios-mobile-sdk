//
//  MastercardWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ClickToPayWidgetView: View {

    @StateObject private var viewModel = ClickToPayWidgetVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                    EmptyView()
                        .sheet(isPresented: $viewModel.showWebView, content: {
                            NavigationStack {
                                VStack {
                                    ClickToPayWidget(
                                        config: ClickToPayWidgetConfig(
                                            serviceId: ProjectEnvironment.shared.getClickToPayServiceId() ?? "",
                                            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                                            meta: nil),
                                        appearance: getAppearance(),
                                        completion: { result in
                                            switch result {
                                            case .success(let result):
                                                viewModel.handleMastercardResult(result)

                                            case .failure(let error):
                                                viewModel.alertMessage = error.localizedDescription
                                                viewModel.showAlert = true
                                            }
                                        })
                                    .navigationTitle("Checkout with Click to Pay")
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        })
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: { }, message: {
            Text(viewModel.alertMessage)
        })
    }

    private func getAppearance() -> ClickToPayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .clickToPay,
            isDarkMode: colorScheme == .dark,
            as: ClickToPayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ClickToPayWidgetAppearance()
    }
}

struct ClickToPayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ClickToPayWidgetView()
    }
}
