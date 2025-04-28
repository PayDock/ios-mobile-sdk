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
    public let colorPalette: ColorPalette
    public let loader: Theme.ButtonLoader
    public let type: ButtonKind
    public let width: CGFloat
    public let height: CGFloat
    
    init(colorPalette: ColorPalette = .blackOnMint,
         loader: Theme.ButtonLoader = Theme.ButtonLoader(),
         type: ButtonKind = .buyNow,
         width: CGFloat,
         height: CGFloat) {
        self.colorPalette = colorPalette
        self.loader = loader
        self.type = type
        self.width = width
        self.height = height
    }
}
