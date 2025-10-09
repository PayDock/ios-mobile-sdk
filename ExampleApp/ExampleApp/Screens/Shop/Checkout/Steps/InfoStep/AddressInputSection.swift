//
//  AddressInputSection.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct AddressInputSection: View {
    let isAddressComplete: Bool
    let formattedAddress: String
    let addressType: String
    let onEnterAddress: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if isAddressComplete {
                // Show filled address with edit option
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(addressType) Address:")
                        .font(.headline)

                    Text(formattedAddress)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(8)

                    Button("Change Address") {
                        onEnterAddress()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.defaultPrimary)
                }
            } else {
                Button("Enter \(addressType) Address") {
                    onEnterAddress()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(Color.defaultPrimary)
                .cornerRadius(8)
            }
        }
    }
}
