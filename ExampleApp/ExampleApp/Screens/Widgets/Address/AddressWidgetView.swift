//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI
import MobileSDK

struct AddressWidgetView: View {
    @State var showAlert = false
    @State var alertMessage = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            AddressWidget(
                config: .init(),
                appearance: getAppearance()) { address in
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
                .alert("Address", isPresented: $showAlert, actions: {}, message: {
                    Text(alertMessage)
                })
        }
    }

    private func getAppearance() -> AddressWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .address,
            isDarkMode: colorScheme == .dark,
            as: AddressWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? AddressWidgetAppearance()
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidgetView()
    }
}
