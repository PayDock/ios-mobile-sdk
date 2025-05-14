//
//  ApplePayButton.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

struct ApplePayButton: View {
    @State var appearance: ApplePayWidgetAppearance
    private let action: () -> Void
    
    init(appearance: ApplePayWidgetAppearance,
         action: @escaping () -> Void) {
        self.appearance = appearance
        self.action = action
    }

    var body: some View {
        Representable(appearance: appearance, action: action)
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
        var action: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(appearance: appearance, action: action)
        }

        func makeUIView(context: Context) -> some UIView {
            context.coordinator.button
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.action = action
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
        }

        @objc
        private func callback(_ sender: Any) {
            action()
        }
    }

}
