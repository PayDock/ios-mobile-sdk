//
//  ApplePayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import PassKit

public struct ApplePayWidgetAppearance {
    public let type: PKPaymentButtonType
    public let style: PKPaymentButtonStyle
    
    public init(type: PKPaymentButtonType = .plain,
                style: PKPaymentButtonStyle = .automatic) {
        self.type = type
        self.style = style
    }
}
