//
//  ApplePaySetupExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct ApplePaySetupExampleView: View {

    // Scales the Apple Pay button height with the system text size so it stays consistent with
    // the SDK's other buttons at larger Dynamic Type sizes. Capped so it doesn't become an
    // oversized empty pill — the PKPaymentButton logo itself is fixed-size and won't scale.
    @ScaledMetric private var applePayHeight: CGFloat = 50

    var body: some View {
        NavigationStack {
            ScrollView {
                // Renders the Apple Pay "Set Up" button — tapping it opens Wallet so the user
                // can add a card. Useful when the device supports Apple Pay but has no eligible
                // card enrolled.
                ApplePaySetupWidget()
                    .frame(height: min(applePayHeight, 64))
                    .accessibilityIdentifier("applePaySetupButton")
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
