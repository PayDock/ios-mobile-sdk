//
//  PaymentInformationCard.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct PaymentInformationCard: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Method")
                .font(.headline)

            if let method = viewModel.selectedPaymentMethod {
                Text(method.displayName)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}
