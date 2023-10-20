//
//  ApplePayButton.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

struct ApplePayButton: View {
    var action: () -> Void

    var body: some View {
        Representable(action: action)
            .frame(minWidth: 100, maxWidth: 400)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
    }
}

struct ApplePayButton_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayButton(action: {})
            .previewLayout(.sizeThatFits)
    }
}

extension ApplePayButton {
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
        var button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)

        init(action: @escaping () -> Void) {
            self.action = action
            super.init()

            setup()
        }

        private func setup() {
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
        }

        @objc
        private func callback(_ sender: Any) {
            action()
        }
    }

}
