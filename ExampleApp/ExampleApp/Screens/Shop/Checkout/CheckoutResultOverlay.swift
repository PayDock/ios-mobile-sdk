//
//  CheckoutResultOverlay.swift
//  ExampleApp
//
//  Created by Assistant on 10.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct CheckoutResultOverlay: View {
    let isSuccess: Bool
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Full screen overlay background
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Content container
                VStack(spacing: 32) {
                    // Icon
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isSuccess ? .green : .red)

                    // Message
                    Text(message)
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 60)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 24)

                Spacer()

                // Bottom button
                VStack(spacing: 0) {
                    Divider()

                    Button(isSuccess ? "Continue" : "Try Again") {
                        onDismiss()
                    }
                    .accessibilityIdentifier(isSuccess ? "Continue" : "Try Again")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.defaultPrimary)
                    .cornerRadius(8)
                    .padding()
                }
                .background(Color(.systemBackground))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSuccess)
    }
}

struct CheckoutResultOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CheckoutResultOverlay(
                isSuccess: true,
                message: "Payment completed successfully!",
                onDismiss: {}
            )
            .previewDisplayName("Success")

            CheckoutResultOverlay(
                isSuccess: false,
                message: "Payment failed. Please try again.",
                onDismiss: {}
            )
            .previewDisplayName("Error")
        }
    }
}
