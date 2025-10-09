//
//  CheckoutProgressIndicator.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct CheckoutProgressIndicator: View {
    let currentStep: CheckoutStep

    var body: some View {
        HStack {
            ForEach(CheckoutStep.allCases, id: \.self) { step in
                HStack {
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(CheckoutStep.allCases.firstIndex(of: step)! + 1)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )

                    if step != CheckoutStep.allCases.last {
                        Rectangle()
                            .fill(stepColor(for: step))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }

    private func stepColor(for step: CheckoutStep) -> Color {
        let currentIndex = CheckoutStep.allCases.firstIndex(of: currentStep) ?? 0
        let stepIndex = CheckoutStep.allCases.firstIndex(of: step) ?? 0

        return stepIndex <= currentIndex ? .defaultPrimary : .gray.opacity(0.3)
    }
}
