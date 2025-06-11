//
//  ColesPayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct ColesPayWidgetAppearance: LoaderStylableAppearance {
    public var loader: Theme.OverlayLoaderAppearance
    
    public init(loader: Theme.OverlayLoaderAppearance = GlobalTheme.shared.globalTheme.loader) {
        self.loader = loader
    }
}

