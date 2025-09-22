//
//  CustomPayPalButtonRepresentable.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 19.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI
import UIKit
import PaymentButtons

struct PayPalButtonRepresentable: UIViewRepresentable {

    let insets: NSDirectionalEdgeInsets?
    let color: PayPalButton.Color
    let edges: PaymentButtonEdges
    let size: PaymentButtonSize
    let label: PayPalButton.Label?
    let isDisabled: Bool
    let action: () -> Void

    func makeUIView(context: Context) -> FullWidthPayPalButtonWrapper {
        let wrapper = FullWidthPayPalButtonWrapper()

        let button = PayPalButton(
            insets: insets,
            color: color,
            edges: edges,
            size: size,
            label: label
        )

        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        wrapper.setupButton(button)

        return wrapper
    }

    func updateUIView(_ wrapper: FullWidthPayPalButtonWrapper, context: Context) {
        wrapper.paypalButton?.isEnabled = !isDisabled
        context.coordinator.action = action
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func buttonTapped() {
            action()
        }
    }
}
