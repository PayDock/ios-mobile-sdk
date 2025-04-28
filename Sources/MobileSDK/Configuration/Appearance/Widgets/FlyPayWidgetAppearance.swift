//
//  FlyPayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct FlyPayWidgetAppearance {
    public let loader: Theme.OverlayLoaderAppearance
    
    init(loader: Theme.OverlayLoaderAppearance = Theme.OverlayLoaderAppearance()) {
        self.loader = loader
    }
}

