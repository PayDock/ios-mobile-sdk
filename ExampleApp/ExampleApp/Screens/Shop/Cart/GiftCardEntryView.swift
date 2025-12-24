//
//  GiftCardEntryView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct GiftCardEntryView: View {
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Gift Card")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Enter your gift card details to apply it to your order")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // Gift Card Widget Integration
                GiftCardWidget(
                    config: GiftCardWidgetConfig(
                        accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                        storePin: false
                    ),
                    completion: { result in
                        switch result {
                        case .success(let giftCardResult):
                            handleGiftCardResult(giftCardResult)
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                )
                .frame(height: 200)

                Spacer()
            }
            .navigationTitle("Gift Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("Cancel Gift Card Entry")
                }
            }
            .alert("Gift Card", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func handleGiftCardResult(_ result: GiftCardResult) {
        // In a real app, you would validate the gift card with your backend
        // For demo purposes, we'll simulate validation
        if let giftCard = cartManager.validateGiftCard(cardNumber: "1234567890123456", pin: "1234") {
            if cartManager.applyGiftCard(giftCard) {
                alertMessage = "Gift card successfully applied!"
                showAlert = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                alertMessage = "This gift card has already been applied or your order total is already covered."
                showAlert = true
            }
        } else {
            alertMessage = "Invalid gift card details. Please check your card number and PIN."
            showAlert = true
        }
    }
}
