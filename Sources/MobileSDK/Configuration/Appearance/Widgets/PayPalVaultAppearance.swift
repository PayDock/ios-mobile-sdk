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

    public init(button: Theme.ButtonAppearance =
        .init(
            colors: .init(background: .clear, text: .defaultPrimary, image: .defaultPrimary, border: .defaultPrimary),
            dimensions: GlobalTheme.shared.globalTheme.actionButton.dimensions,
            fonts: GlobalTheme.shared.globalTheme.actionButton.fonts,
            loader: .init(spinnerColor: .defaultPrimary))) {
                self.actionButton = button
            }
}
