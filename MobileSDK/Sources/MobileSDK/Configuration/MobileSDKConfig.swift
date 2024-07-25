//
//  MobileSDKConfig.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

public struct MobileSDKConfig {

    var environment: SDKEnvironment
    let theme: Theme?

    public init(environment: SDKEnvironment,
                theme: Theme? = nil) {
        self.environment = environment
        self.theme = theme

        setup()
    }

    private func setup() {
        setupTheme()
    }

    private func setupTheme() {
        guard let theme = theme else { return }
        
        Appearance.shared.lightThemeColors = theme.lightThemeColors
        Appearance.shared.darkThemeColors = theme.darkThemeColors
        Appearance.shared.dimensions = theme.dimensions
        Appearance.shared.fontName = theme.fontName
    }

}
