//
//  Integrated3DSWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

public struct Integrated3DSWidgetAppearance {
    public let loader: Theme.OverlayLoaderAppearance
    
    init(loader: Theme.OverlayLoaderAppearance = Theme.OverlayLoaderAppearance()) {
        self.loader = loader
    }
}
