//
//  ClickToPayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

public struct ClickToPayWidgetAppearance: LoaderStylableAppearance {
    public var loader: Theme.OverlayLoaderAppearance
    
    public init(loader: Theme.OverlayLoaderAppearance = .init(
        color: GlobalTheme.shared.globalTheme.loader.color,
        overlayColor: .clear)) {
            self.loader = loader
    }
}
