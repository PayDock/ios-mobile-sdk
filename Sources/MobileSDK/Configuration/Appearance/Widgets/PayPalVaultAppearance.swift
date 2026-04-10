//
//  PayPalVaultAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct PayPalVaultAppearance: ActionButtonStylableAppearance {

    public var actionButton: Theme.ButtonAppearance

    public init(button: Theme.ButtonAppearance? = nil) {

        guard let button else {
            // If no appearance set, default to global theme
            self.actionButton = GlobalTheme.shared.globalTheme.actionButton
            self.actionButton.colors.background = .clear
            self.actionButton.colors.text = .defaultPrimary
            self.actionButton.colors.image = .defaultPrimary
            self.actionButton.colors.border = .defaultPrimary
            self.actionButton.loader = .init(spinnerColor: .defaultPrimary)
            self.actionButton.icon = Image("link", bundle: MobileSDK.bundle)
            self.actionButton.text = "Link PayPal account"
            return
        }

        self.actionButton = button
    }
}
