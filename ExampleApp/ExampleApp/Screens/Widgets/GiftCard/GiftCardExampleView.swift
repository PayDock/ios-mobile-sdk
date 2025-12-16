//
//  GiftCardExampleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct GiftCardExampleView: View {

    @StateObject var viewModel = GiftCardExampleVM()
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var configManager = ConfigManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget(
                    config: viewModel.getConfig(),
                    appearance: getAppearance(),
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

    private func getAppearance() -> GiftCardWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .giftCard,
            isDarkMode: colorScheme == .dark,
            as: GiftCardWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? GiftCardWidgetAppearance()
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardExampleView()
    }
}
