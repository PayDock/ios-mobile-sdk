//
//  PayPalVaultAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct PayPalVaultAppearance {
    public let loader: Theme.ButtonLoader
    
    init(loader: Theme.ButtonLoader = Theme.ButtonLoader()) {
        self.loader = loader
    }
}

