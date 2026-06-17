//
//  Standalone3dsWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

public struct Standalone3dsWidgetAppearance: OverlayLoaderStylableAppearance {

    public var overlayLoader: Theme.OverlayLoaderAppearance

    public init(overlayLoader: Theme.OverlayLoaderAppearance = {
        var defaults = GlobalTheme.shared.globalTheme.overlayLoader
        defaults.loaderText = "Processing payment..."
        return defaults
    }()) {
        self.overlayLoader = overlayLoader
    }
}
