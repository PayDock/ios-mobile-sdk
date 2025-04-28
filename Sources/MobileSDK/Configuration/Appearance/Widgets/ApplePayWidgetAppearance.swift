//
//  ApplePayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import PassKit

public struct ApplePayWidgetAppearance {
    public let style: PKPaymentButtonStyle
    public let cornerRadius: CGFloat
    
    init(style: PKPaymentButtonStyle = .automatic,
         cornerRadius: CGFloat) {
        self.style = style
        self.cornerRadius = cornerRadius
    }
}
