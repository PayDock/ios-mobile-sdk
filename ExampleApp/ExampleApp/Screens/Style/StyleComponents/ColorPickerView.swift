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
                }
                ColorPicker(selection: $pickedColor, supportsOpacity: false, label: {})
                .frame(width: 44, height: 44)
                .padding(.trailing, 24)
            }
        }
    }
}

#Preview {
    ColorPickerView(title: "Pick the color", text: .constant("ASDF"), pickedColor: .constant(.green))
}
