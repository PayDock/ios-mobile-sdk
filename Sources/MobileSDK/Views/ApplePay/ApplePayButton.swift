//
//  ApplePayButton.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import PassKit

struct ApplePayButton: View {
    @State var appearance: ApplePayWidgetAppearance
    private let isDisabled: Bool
    private let action: () -> Void

    init(appearance: ApplePayWidgetAppearance,
         isDisabled: Bool = false,
         action: @escaping () -> Void) {
        self.appearance = appearance
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Representable(appearance: appearance, isDisabled: isDisabled, action: action)
    }
}

struct ApplePayButton_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayButton(appearance: ApplePayWidgetAppearance(), action: {})
            .previewLayout(.sizeThatFits)
    }
}

extension ApplePayButton {
    struct Representable: UIViewRepresentable {
        var appearance: ApplePayWidgetAppearance
        var isDisabled: Bool
        var action: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(appearance: appearance, action: action)
        }

        func makeUIView(context: Context) -> some UIView {
            context.coordinator.button
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.action = action
            context.coordinator.appearance = appearance
            context.coordinator.button.isEnabled = !isDisabled
            if let cornerRadius = appearance.cornerRadius {
                context.coordinator.button.cornerRadius = cornerRadius
            }
        }
    }

    class Coordinator: NSObject {
        var appearance: ApplePayWidgetAppearance
        var action: () -> Void
        var button: PKPaymentButton

        init(appearance: ApplePayWidgetAppearance, action: @escaping () -> Void) {
            self.appearance = appearance
            self.action = action
            self.button = PKPaymentButton(paymentButtonType: appearance.type, paymentButtonStyle: appearance.style)
            super.init()

            setup()
        }

        private func setup() {
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
            if let cornerRadius = appearance.cornerRadius {
                button.cornerRadius = cornerRadius
            }
        }

        @objc
        private func callback(_ sender: Any) {
            action()
        }
    }
}
