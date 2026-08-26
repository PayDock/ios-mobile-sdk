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
    public var loader: Theme.LoaderAppearance
    public var type: ButtonKind

    // Afterpay 5.9.0 rebranded its ColorPalette: the former `.blackOnMint` (the default
    // black-on-mint Afterpay look) is now expressed as `.default`.
    public init(colorScheme: ColorScheme = .static(.default),
                loader: Theme.LoaderAppearance = GlobalTheme.shared.globalTheme.loader,
                type: ButtonKind = .buyNow) {
        self.colorScheme = colorScheme
        self.loader = loader
        self.type = type
    }
}
