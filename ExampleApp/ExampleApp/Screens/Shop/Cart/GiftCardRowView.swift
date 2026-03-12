//
//  GiftCardRowView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct GiftCardRowView: View {
    let appliedGiftCard: AppliedGiftCard
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(appliedGiftCard.giftCard.maskedCardNumber)
                    .font(.system(size: 16, weight: .medium))

                Text("Applied: \(appliedGiftCard.formattedAppliedAmount)")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .accessibilityIdentifier("Remove Gift Card \(appliedGiftCard.giftCard.maskedCardNumber)")
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 1)
        )
    }
}
