//
//  CheckoutAddressWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CheckoutAddressWidgetView: View {
    let type: AddressWidgetType
    let existingAddress: Address?
    let onAddressSelected: (Address) -> Void
    let onCancel: () -> Void

    var title: String {
        switch type {
        case .shipping: return "Shipping Address"
        case .billing: return "Billing Address"
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Enter \(title)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                AddressWidget(
                    config: AddressWidgetConfig(
                        address: existingAddress
                    ),
                    appearance: getAppearance(),
                    completion: { result in
                        onAddressSelected(result)
                    }
                )

                Spacer()
            }
            .background(Color.white)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }

    private func getAppearance() -> AddressWidgetAppearance {
        let text = existingAddress == nil ? "Add" : "Save"
        let icon = existingAddress == nil ? Image(systemName: "plus.circle") : nil

        var appearance = AddressWidgetAppearance()
        appearance.actionButton = .init(icon: icon, text: text)
        return appearance
    }
}
