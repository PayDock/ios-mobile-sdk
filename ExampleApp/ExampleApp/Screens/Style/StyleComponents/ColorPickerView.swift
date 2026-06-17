//
//  ColorPickerView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ColorPickerView: View {

    let title: String
    @Binding var text: String
    @Binding var pickedColor: Color

    /// `ColorPicker(supportsOpacity: false)` won't let you select a colour when its bound value
    /// is `.clear` (alpha 0) — the well treats it as "no colour" and selections don't commit.
    /// Present an opaque proxy (white) to the picker when the value is clear so it stays
    /// interactive, while still writing the user's selection straight back to `pickedColor`.
    private var pickerSelection: Binding<Color> {
        Binding(
            get: { pickedColor == .clear ? .white : pickedColor },
            set: { pickedColor = $0 }
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .padding(.leading, 16)
                    .padding(.bottom, -4)
                Spacer()
            }
            HStack {
                ZStack {
                    Rectangle()
                        .frame(height: 40)
                        .foregroundColor(Color.white)
                        .padding(.leading, 16)

                    TextField(title, text: $text)
                        .frame(height: 40)
                        .background(Color.white)
                        .padding(.leading, 32)
                        .accessibilityIdentifier("TextField_\(title)")
                }
                ColorPicker(selection: pickerSelection, supportsOpacity: false, label: {})
                .frame(width: 44, height: 44)
                .padding(.trailing, 24)
                .accessibilityIdentifier("ColorPicker_\(title)")
            }
        }
    }
}

#Preview {
    ColorPickerView(title: "Pick the color", text: .constant("ASDF"), pickedColor: .constant(.green))
}
