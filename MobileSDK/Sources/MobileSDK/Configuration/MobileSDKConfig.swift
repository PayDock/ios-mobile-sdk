//
//  MobileSDKConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

public struct MobileSDKConfig {

    var environment: SDKEnvironment
    let theme: Theme

    public init(environment: SDKEnvironment,
                theme: Theme) {
        self.environment = environment
        self.theme = theme

        setup()
    }

    private func setup() {
        setupTheme()
    }

    private func setupTheme() {
        Appearance.shared.lightThemeColors = theme.lightThemeColors
        Appearance.shared.darkThemeColors = theme.darkThemeColors
        Appearance.shared.dimensions = theme.dimensions
        Appearance.shared.fontName = theme.fontName
    }

}
