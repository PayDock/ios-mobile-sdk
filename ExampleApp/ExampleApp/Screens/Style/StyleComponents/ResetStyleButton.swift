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

    init(action: @escaping () -> Void) {
        self.action = action
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
    }
}

#Preview {
    VStack {
        ResetStyleButton(action: {})
    }
}
