//
//  AddressWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.11.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import OSLog

@MainActor
class AddressWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Config

    func getConfig() -> AddressWidgetConfig {
        return AddressWidgetConfig()
    }

    // MARK: - Completion handling

    func handleAddressCompletion(_ address: Address) {
        alertTitle = "Address"
        alertMessage = """
        \(address.firstName) \(address.lastName)
        \(address.addressLine1)
        \(address.addressLine2)
        \(address.city)
        \(address.state)
        \(address.postcode)
        \(address.country)
        """
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension AddressWidgetVM: WidgetEventDelegate {
    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
