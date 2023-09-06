//
//  WidgetsVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import SwiftUI
import MobileSDK

class WidgetsVM: ObservableObject {
    
    private let mobileSDK: MobileSDK
    
    init(mobileSDK: MobileSDK = MobileSDK.shared) {
        self.mobileSDK = mobileSDK

        initialiseMobileSDK()
    }

    private func initialiseMobileSDK() {
        let lightThemeColors = Colors(
            primary: Color(red: 0.4, green: 0.31, blue: 0.64),
            onPrimary: .white,
            text: .black,
            success: Color(red: 0.55, green: 0.55, blue: 0.55),
            error: Color(red: 0.7, green: 0.15, blue: 0.12),
            background: .white,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let darkThemeColors = Colors(
            primary: .purple,
            onPrimary: .white,
            text: .white,
            success: Color(red: 0.55, green: 0.55, blue: 0.55),
            error: .red,
            background: .black,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let dimensions = Dimensions(cornerRadius: 4, borderWidth: 1, spacing: 16)

        let theme = Theme(
            lighThemeColorst: lightThemeColors,
            darkThemeColors: darkThemeColors,
            dimensions: dimensions)

        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production, theme: theme)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox, theme: theme)
        case .staging: config = MobileSDKConfig(environment: .staging, theme: theme)
        }

        mobileSDK.configureMobileSDK(config: config)
    }
    
}
