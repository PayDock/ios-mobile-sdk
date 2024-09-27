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
    let enableTestMode: Bool

    public init(environment: SDKEnvironment,
                theme: Theme? = nil,
                enableTestMode: Bool = false) {
        self.environment = environment
        self.theme = theme
        // If the environment is production, force enableTestMode to be false
        // Otherwise, use the value passed in enableTestMode
        self.enableTestMode = (environment == .production) ? false : enableTestMode

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
