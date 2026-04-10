//
//  ApplePayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import PassKit

public struct ApplePayWidgetAppearance {
    public var type: PKPaymentButtonType
    public var style: PKPaymentButtonStyle
    public var cornerRadius: CGFloat?

    public init(type: PKPaymentButtonType = .plain,
                style: PKPaymentButtonStyle = .automatic,
                cornerRadius: CGFloat? = nil) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }
}
