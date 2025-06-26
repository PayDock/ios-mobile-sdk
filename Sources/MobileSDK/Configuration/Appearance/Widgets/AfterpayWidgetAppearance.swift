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
    
    public init(colorScheme: ColorScheme = .static(.blackOnMint),
                loader: Theme.OverlayLoaderAppearance = GlobalTheme.shared.globalTheme.loader,
                type: ButtonKind = .buyNow) {
        self.colorScheme = colorScheme
        self.loader = loader
        self.type = type
    }
}
