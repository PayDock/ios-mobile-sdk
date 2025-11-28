//
//  CardDetailsWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.11.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import OSLog

@MainActor
class CardDetailsWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Config

    func getConfig() -> CardDetailsWidgetConfig {
        return CardDetailsWidgetConfig(
            gatewayId: ProjectEnvironment.shared.getMPGSGatewayId(),
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            allowSaveCard: SaveCardConfig(
                consentText: "Remember this card for next time.",
                privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                    privacyPolicyText: "Read our privacy policy",
                    privacyPolicyURL: "https://www.google.com")),
            schemeSupport: SupportedSchemesConfig(
                supportedSchemes: Set(CardScheme.allCases),
                enableValidation: true
            )
        )
    }

    // MARK: - Completion handling

    func handleSuccess(_ result: CardResult) {
        alertTitle = "Success"
        alertMessage = result.token
        showAlert = true
    }

    func handleError(_ error: CardDetailsError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension CardDetailsWidgetVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
