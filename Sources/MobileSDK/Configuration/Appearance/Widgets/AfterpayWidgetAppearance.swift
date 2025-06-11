//
//  AfterpayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import Afterpay

public struct AfterpayWidgetAppearance: LoaderStylableAppearance {
    public var colorScheme: Afterpay.ColorScheme
    public var loader: Theme.OverlayLoaderAppearance
    public var type: ButtonKind
    public var width: CGFloat
    public var height: CGFloat
    
    public init(colorScheme: ColorScheme = .static(.blackOnMint),
                loader: Theme.OverlayLoaderAppearance = GlobalTheme.shared.globalTheme.loader,
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
