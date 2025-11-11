//
//  GiftCardWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.11.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import OSLog

@MainActor
class GiftCardWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Config

    func getConfig() -> GiftCardWidgetConfig {
        return GiftCardWidgetConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            storePin: false)
    }

    // MARK: - Completion handling

    func handleSuccess(_ result: GiftCardResult) {
        alertTitle = "Success"
        alertMessage = result.token
        showAlert = true
    }

    func handleError(_ error: GiftCardError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension GiftCardWidgetVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
