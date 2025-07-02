//
//  PayPalWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct PayPalWidgetAppearance: ActionButtonLoaderStylableAppearance {
    public var loader: Theme.ButtonLoader
    
    public init(loader: Theme.ButtonLoader = .init(spinnerColor: .black)) {
        self.loader = loader
    }
}

