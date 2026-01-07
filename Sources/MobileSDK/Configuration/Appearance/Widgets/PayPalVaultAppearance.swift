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
        // Custom
        self.actionButton = button
        self.actionButton.colors.background = .clear
        self.actionButton.colors.text = .defaultPrimary
        self.actionButton.colors.image = .defaultPrimary
        self.actionButton.colors.border = .defaultPrimary
        self.actionButton.loader = .init(spinnerColor: .defaultPrimary)
        self.actionButton.icon = Image("link", bundle: MobileSDK.bundle)
        self.actionButton.text = "Link PayPal account"
    }
}
