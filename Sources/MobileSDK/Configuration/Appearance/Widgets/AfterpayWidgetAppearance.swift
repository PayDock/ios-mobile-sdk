//
//  AfterpayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import Afterpay

public struct AfterpayWidgetAppearance {
    public let colorScheme: Afterpay.ColorScheme
    public let loader: Theme.OverlayLoaderAppearance
    public let type: ButtonKind
    public let width: CGFloat
    public let height: CGFloat
    
    public init(colorScheme: ColorScheme = .static(.blackOnMint),
         loader: Theme.OverlayLoaderAppearance = Theme.OverlayLoaderAppearance(),
         type: ButtonKind = .buyNow,
         width: CGFloat = 360,
         height: CGFloat = 36) {
        self.colorScheme = colorScheme
        self.loader = loader
        self.type = type
        self.width = width
        self.height = height
    }
}
