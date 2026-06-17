//
//  OpacitySliderView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

struct OpacitySliderView: View {

    let title: String
    @Binding var value: Double

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .padding(.bottom, -4)
                Spacer()
            }
            HStack(spacing: 12) {
                Slider(value: $value, in: 0...1, step: 0.01)
                    .frame(height: 40)
                    .tint(.defaultPrimary)

                Text(String(format: "%.0f%%", value * 100))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, 16.0)
    }
}

#Preview {
    OpacitySliderView(title: "Disabled opacity", value: .constant(0.8))
        .background(Color(hex: "#EAE0D7"))
}
