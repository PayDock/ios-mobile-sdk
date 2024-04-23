//
//  AfterpayPaymentButton.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import UIKit
import Afterpay

struct AfterpayPaymentButton: View {
    var action: () -> Void

    var body: some View {
        Representable(action: action)
    }
}

struct AfterpayPaymentButton_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayPaymentButton(action: {})
            .previewLayout(.sizeThatFits)
    }
}

extension AfterpayPaymentButton {
    struct Representable: UIViewRepresentable {
        var action: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(action: action)
        }

        func makeUIView(context: Context) -> some UIView {
            context.coordinator.button
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.action = action
        }
    }

    class Coordinator: NSObject {
        var action: () -> Void
        var button = PaymentButton(colorScheme: .dynamic(lightPalette: .blackOnMint, darkPalette: .mintOnBlack), buttonKind: .payNow)

        init(action: @escaping () -> Void) {
            self.action = action
            super.init()

            setup()
        }

        private func setup() {
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
                button.heightAnchor.constraint(equalToConstant: 50),
            ])
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
        }

        @objc private func callback(_ sender: Any) {
            action()
        }
    }

}
