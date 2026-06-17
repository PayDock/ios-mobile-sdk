//
//  ToggleFieldView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct ToggleFieldView: View {
    let title: String
    @Binding var isOn: Bool
    let onChange: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.black)

            Spacer()

            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _ in
                    onChange()
                }
                .frame(width: 80.0)
                .accessibilityIdentifier("Toggle_\(title)")
                .accessibilityLabel(title)
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 8.0)
    }
}
