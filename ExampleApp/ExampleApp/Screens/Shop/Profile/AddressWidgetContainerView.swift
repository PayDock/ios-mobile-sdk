//
//  AddressWidgetContainerView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct AddressWidgetContainerView: View {
    let address: Address?
    let onAddressSelected: (Address) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Enter Your Address")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                AddressWidget(
                    config: AddressWidgetConfig(
                        address: address
                    ),
                    appearance: getAppearance(),
                    completion: { result in
                        onAddressSelected(result)
                    }
                )

                Spacer()
            }
            .navigationTitle("Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func getAppearance() -> AddressWidgetAppearance {
        let text = address == nil ? "Add" : "Save"
        let icon = address == nil ? Image(systemName: "plus.circle") : nil

        var appearance = AddressWidgetAppearance()
        appearance.actionButton = .init(icon: icon, text: text)
        return appearance
    }
}
