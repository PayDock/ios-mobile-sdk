//
//  ThreeDSWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

public struct ThreeDSWidgetAppearance {
    
    public let loader: Theme.OverlayLoaderAppearance
    
    public init(loader: Theme.OverlayLoaderAppearance = Theme.OverlayLoaderAppearance()) {
        self.loader = loader
    }
}
