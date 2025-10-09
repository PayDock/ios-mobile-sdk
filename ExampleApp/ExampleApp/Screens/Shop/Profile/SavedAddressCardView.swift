//
//  SavedAddressCardView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct SavedAddressCardView: View {
    let address: SavedAddress
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(address.label)
                    .font(.headline)

                if address.isDefault {
                    Text("DEFAULT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }

                Spacer()

                Menu {
                    Button("Edit", action: onEdit)

                    if !address.isDefault {
                        Button("Set as Default", action: onSetDefault)
                    }

                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.defaultPrimary)
                }
            }

            Text(address.formattedAddress)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            if !address.isComplete {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)

                    Text("Address incomplete")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(address.isDefault ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}
