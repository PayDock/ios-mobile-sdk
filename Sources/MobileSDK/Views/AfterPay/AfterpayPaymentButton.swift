//
//  AfterpayPaymentButton.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import UIKit
import Afterpay

struct AfterpayPaymentButton: View {
    var colorScheme: Afterpay.ColorScheme
    var type: ButtonKind
    var action: () -> Void

    var body: some View {
        Representable(colorScheme: colorScheme, type: type, action: action)
            .frame(maxWidth: .infinity)
    }
}

struct AfterpayPaymentButton_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayPaymentButton(colorScheme: .static(.default), type: .buyNow, action: {})
            .previewLayout(.sizeThatFits)
    }
}

extension AfterpayPaymentButton {
    struct Representable: UIViewRepresentable {
        var colorScheme: Afterpay.ColorScheme
        var type: ButtonKind
        var action: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(colorScheme: colorScheme, type: type, action: action)
        }

        func makeUIView(context: Context) -> some UIView {
            let container = UIView()
            let button = context.coordinator.button

            button.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)

            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor),
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            return container
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.action = action
        }
    }

    class Coordinator: NSObject {
        var colorScheme: Afterpay.ColorScheme
        var type: ButtonKind
        var action: () -> Void

        lazy var button = PaymentButton(colorScheme: colorScheme, buttonKind: type)

        init(colorScheme: Afterpay.ColorScheme, type: ButtonKind, action: @escaping () -> Void) {
            self.colorScheme = colorScheme
            self.type = type
            self.action = action
            super.init()

            setup()
        }

        private func setup() {
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
        }

        @objc private func callback(_ sender: Any) {
            action()
        }
    }
}
