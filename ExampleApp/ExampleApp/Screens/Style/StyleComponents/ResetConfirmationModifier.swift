//
//  ResetConfirmationModifier.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 16.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct ResetConfirmationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .alert("Reset to defaults", isPresented: $isPresented) {
                Button("Yes", role: .destructive) {
                    onConfirm()
                }
                .accessibilityIdentifier("Alert_Button_Yes_ResetToDefaults")

                Button("No", role: .cancel) {}
                    .accessibilityIdentifier("Alert_Button_No_ResetToDefaults")
            } message: {
                Text("Are you sure you want to reset your settings to their original values?")
            }
    }
}

extension View {
    func resetConfirmationAlert(isPresented: Binding<Bool>, onConfirm: @escaping () -> Void) -> some View {
        self.modifier(ResetConfirmationModifier(isPresented: isPresented, onConfirm: onConfirm))
    }
}
