//
//  ResetStyleButton.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 16.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct ResetStyleButton: View {
    
    let action: () -> Void
    let isDisabled: Bool
    
    init(isDisabled: Bool, action: @escaping () -> Void) {
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Reset to defaults")
        }
        .frame(height: 50.0)
        .frame(maxWidth: .infinity)
        .overlay(
            Rectangle()
                .stroke(Color.black, lineWidth: 1.0)
        )
        .padding(.top, 16.0)
        .padding()
        .opacity(isDisabled ? 0.5 : 1.0)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        ResetStyleButton(isDisabled: true, action: {})
    }
}
