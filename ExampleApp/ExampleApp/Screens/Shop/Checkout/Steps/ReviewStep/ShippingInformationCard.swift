//
//  ShippingInformationCard.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ShippingInformationCard: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shipping Information")
                .font(.headline)

            Text(viewModel.fullName)
                .font(.body)

            Text(viewModel.email)
                .font(.body)
                .foregroundColor(.gray)

            Text(viewModel.phone)
                .font(.body)
                .foregroundColor(.gray)

            Text(viewModel.formattedShippingAddress)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}
