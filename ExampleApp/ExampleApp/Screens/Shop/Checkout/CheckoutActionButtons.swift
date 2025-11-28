//
//  CheckoutActionButtons.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct CheckoutActionButtons: View {
    let currentStep: CheckoutStep
    let canProceed: Bool
    let onBack: () -> Void
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                if currentStep != .information {
                    Button("Back") {
                        onBack()
                    }
                    .foregroundColor(.defaultPrimary)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.defaultPrimary, lineWidth: 1)
                    )
                }

                if currentStep == .information {
                    Button(actionButtonTitle) {
                        onAction()
                    }

                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(canProceed ? Color.defaultPrimary : Color.gray)
                    .cornerRadius(8)
                    .disabled(!canProceed)
                }
            }
            .ignoresSafeArea()
            .padding()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var actionButtonTitle: String {
        switch currentStep {
        case .information: return "Continue to Payment"
        case .paymentAndReview: return "Place Order"
        }
    }
}
