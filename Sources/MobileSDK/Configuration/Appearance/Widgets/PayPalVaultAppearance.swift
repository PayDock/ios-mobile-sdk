//
//  PayPalVaultAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct PayPalVaultAppearance: ActionButtonStylableAppearance {
    
    public var actionButton: Theme.ButtonAppearance
    
    public init(button: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton) {
            self.actionButton = button
        }
}

