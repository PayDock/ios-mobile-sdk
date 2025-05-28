//
//  PayPalVaultAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct PayPalVaultAppearance {
    
    public let button: Theme.ButtonAppearance
    
    public init(button: Theme.ButtonAppearance = Theme.ButtonAppearance(
        colors: .init(background: .defaultBackground,
                      text: .defaultPrimary,
                      image: .defaultPrimary,
                      border: .defaultPrimary),
        loader: .init(spinnerColor: .defaultPrimary))) {
        self.button = button
    }
}

