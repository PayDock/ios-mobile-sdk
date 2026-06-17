//
//  ApplePaySetupExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct ApplePaySetupExampleView: View {

    var body: some View {
        NavigationStack {
            ScrollView {
                // Renders the Apple Pay "Set Up" button — tapping it opens Wallet so the user
                // can add a card. Useful when the device supports Apple Pay but has no eligible
                // card enrolled.
                ApplePaySetupWidget()
                    .frame(height: 50)
                    .padding()
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct ApplePaySetupExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePaySetupExampleView()
    }
}
