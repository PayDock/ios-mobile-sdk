//
//  PayPalVaultWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.10.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class PayPalVaultWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    // MARK: - Completion handling

    func handleError(error: PayPalVaultError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }

    func handleSuccess(result: PayPalVaultResult) {
        alertTitle = "Success"
        alertMessage = "Approval session ID:\n \(result.token)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }
}
