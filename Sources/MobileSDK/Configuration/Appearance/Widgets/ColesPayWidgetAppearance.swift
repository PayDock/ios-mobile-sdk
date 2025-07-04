//
//  ColesPayWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct ColesPayWidgetAppearance: ActionButtonLoaderStylableAppearance {
    public var loader: Theme.ButtonLoader
    
    public init(loader: Theme.ButtonLoader = GlobalTheme.shared.globalTheme.actionButton.loader) {
        self.loader = loader
    }
}

