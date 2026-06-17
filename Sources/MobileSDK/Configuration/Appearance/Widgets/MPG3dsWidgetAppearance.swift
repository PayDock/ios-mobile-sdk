//
//  MPG3dsWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

public struct MPG3dsWidgetAppearance: LoaderStylableAppearance {

    public var loader: Theme.LoaderAppearance

    public init(loader: Theme.LoaderAppearance = .init(
        color: GlobalTheme.shared.globalTheme.loader.color,
        overlayColor: .clear)) {
            self.loader = loader
        }
}
