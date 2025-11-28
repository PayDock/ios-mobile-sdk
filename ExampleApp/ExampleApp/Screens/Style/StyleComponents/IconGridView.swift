//
//  IconGridView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 17.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct IconGridView: View {

    let entries: [String]
    @Binding var selectedIcon: Image?
    @Environment(\.dismiss) var dismiss
    var onSelection: (Image?) -> Void

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // No Icon option
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                        }

                        Text("No Icon")
                            .font(.caption2)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .frame(height: 32)
                    }
                    .onTapGesture {
                        selectedIcon = nil
                        onSelection(nil)
                        dismiss()
                    }

                    ForEach(entries, id: \.self) { iconName in
                        VStack(spacing: 4) {
                            Image(systemName: iconName)
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            Text(iconName)
                                .font(.caption2)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .frame(height: 32)
                        }
                        .onTapGesture {
                            selectedIcon = Image(systemName: iconName)
                            onSelection(Image(systemName: iconName))
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
