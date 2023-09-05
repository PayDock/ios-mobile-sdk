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
//        let lightThemeColors = Theme.Colors(
//            primary: Color(red: 0.4, green: 0.31, blue: 0.64),
//            onPrimary: .white,
//            text: .black,
//            success: Color(red: 0.55, green: 0.55, blue: 0.55),
//            error: Color(red: 0.7, green: 0.15, blue: 0.12),
//            background: .white,
//            border: Color(red: 0.55, green: 0.55, blue: 0.55),
//            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let lightThemeColors = Theme.Colors(
            primary: .brown,
            onPrimary: .blue,
            text: .green,
            success: .black,
            error: .pink,
            background: .yellow,
            border: .orange,
            placeholder: .cyan)

        let darkThemeColors = Theme.Colors(
            primary: .purple,
            onPrimary: .white,
            text: .white,
            success: Color(red: 0.55, green: 0.55, blue: 0.55),
            error: Color(red: 0.7, green: 0.15, blue: 0.12),
            background: .black,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let theme = Theme(lighThemeColorst: lightThemeColors, darkThemeColors: darkThemeColors)

        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production, theme: theme)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox, theme: theme)
        case .staging: config = MobileSDKConfig(environment: .staging, theme: theme)
        }

        mobileSDK.configureMobileSDK(config: config)
        mobileSDK.printCurrentEnvironment()

        
    }
    
}
