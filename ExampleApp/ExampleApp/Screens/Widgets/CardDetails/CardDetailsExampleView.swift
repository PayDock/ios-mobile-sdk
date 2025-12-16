//
//  CardDetailsExampleView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.07.2023..
//

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
                    config: configManager.getCardDetailsConfig(),
                    appearance: getAppearance(),
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

    private func getAppearance() -> CardDetailsWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .card,
            isDarkMode: colorScheme == .dark,
            as: CardDetailsWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? CardDetailsWidgetAppearance()
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsExampleView()
    }
}
