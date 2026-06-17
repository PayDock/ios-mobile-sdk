//
//  PayPalVaultAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct PayPalVaultAppearance: ActionButtonStylableAppearance {

    public var actionButton: Theme.ButtonAppearance

    public init(button: Theme.ButtonAppearance = {
        var defaults = GlobalTheme.shared.globalTheme.actionButton
        defaults.colors.background = .clear
        defaults.colors.text = .defaultPrimary
        defaults.colors.image = .defaultPrimary
        defaults.colors.border = .defaultPrimary
        defaults.loader = .init(spinnerColor: .defaultPrimary)
        defaults.icon = Image("link", bundle: MobileSDK.bundle)
        defaults.text = "Link PayPal account"
        defaults.accessibilityHint = "Double tap to open browser and link account"
        return defaults
    }()) {
        self.actionButton = button
    }
}
