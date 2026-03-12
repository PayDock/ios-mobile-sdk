//
//  ClickToPayExampleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class ClickToPayExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showWebView = true
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    func getConfig() -> ClickToPayWidgetConfig {
        return configManager.getClickToPayConfig()
    }

    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }

    func handleMastercardResult(_ result: ClickToPayResult) {
        switch result.event {
        case .checkoutCompleted:
            showWebView = false
            alertTitle = "Checkout successful"
            alertMessage = "Mastercard token:\n\(result.mastercardToken)"
            showAlert = true

        case .checkoutReady:
            print("Checkout ready")

        case .checkoutError:
            showWebView = false
            alertTitle = "Checkout failure"
            alertMessage = "Please try again."
            showAlert = true
        }
    }

}
