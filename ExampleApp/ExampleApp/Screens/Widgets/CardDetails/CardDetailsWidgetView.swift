//
//  CardDetailsWidgetView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI
import MobileSDK

struct CardDetailsWidgetView: View {
    @StateObject var viewModel = CardDetailsWidgetVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                CardDetailsWidget(
                    config: viewModel.getConfig(),
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
        CardDetailsWidgetView()
    }
}
