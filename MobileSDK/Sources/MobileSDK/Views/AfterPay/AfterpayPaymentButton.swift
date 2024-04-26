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
    var width: CGFloat
    var action: () -> Void

    var body: some View {
        Representable(action: action, width: width)
    }
}

struct AfterpayPaymentButton_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayPaymentButton( width: 320, action: {})
            .previewLayout(.sizeThatFits)
    }
}

extension AfterpayPaymentButton {
    struct Representable: UIViewRepresentable {
        var action: () -> Void
        var width: CGFloat

        func makeCoordinator() -> Coordinator {
            Coordinator(width: width, action: action)
        }

        func makeUIView(context: Context) -> some UIView {
            context.coordinator.button
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.action = action
            context.coordinator.width = width
        }
    }

    class Coordinator: NSObject {
        var width: CGFloat
        var action: () -> Void
        var button = PaymentButton(colorScheme: .dynamic(lightPalette: .blackOnMint, darkPalette: .mintOnBlack), buttonKind: .payNow)

        init(width: CGFloat, action: @escaping () -> Void) {
            self.action = action
            self.width = width
            super.init()

            setup()
        }

        private func setup() {
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: width),
            ])
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
        }

        @objc private func callback(_ sender: Any) {
            action()
        }
    }

}
