//
//  StyleDarkModeButton.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct StyleDarkModeButton: View {
    
    var isSelected: Bool
    let icon: Image
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            icon // Replace with your template image name
                .renderingMode(.template)
                .frame(width: 28.0, height: 28.0)
                .foregroundColor(isSelected ? .white : .black)
                .background(isSelected ? Color.black : Color.white)
                .clipShape(Circle())
        }
        .buttonStyle(.borderless)
        .frame(width: 44.0, height: 44.0)
        .contentShape(Circle())
    }
}

#Preview {
    StyleDarkModeButton(isSelected: true, icon: Image("moon"), action: {})
}
