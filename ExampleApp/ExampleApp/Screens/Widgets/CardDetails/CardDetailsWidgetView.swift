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
    @State var isSheetPresented = false
    @State var showAlert = false
    @State var alertMessage = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                CardDetailsWidget(
                    config: CardDetailsWidgetConfig(
                        gatewayId: nil,
                        accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                        allowSaveCard: SaveCardConfig(consentText: "Remember this card for next time.", privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(privacyPolicyText: "Read our privacy policy", privacyPolicyURL: "https://www.google.com")),
                        schemeSupport: SupportedSchemesConfig(
                            supportedSchemes: Set(CardScheme.allCases),
                            enableValidation: true
                        )
                    ),
                    appearance: getAppearance(),
                    completion: { result in
                        switch result {
                        case .success(let result): alertMessage = result.token
                        case .failure(let error): alertMessage = error.localizedDescription
                        }
                        showAlert = true
                    })
            }
            .alert("Card Details", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
        .alert("Card Details", isPresented: $showAlert, actions: {}, message: {
            Text(alertMessage)
        })
    }
    
    private func getAppearance() -> CardDetailsWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(for: .card, isDarkMode: colorScheme == .dark, as: CardDetailsWidgetAppearance.self, shouldCreateDefaultIfNeeded: false)
        return appearance ?? CardDetailsWidgetAppearance()
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidgetView()
    }
}
