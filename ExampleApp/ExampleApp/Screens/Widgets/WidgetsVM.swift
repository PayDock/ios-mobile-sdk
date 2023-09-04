//
//  WidgetsVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation
import MobileSDK

class WidgetsVM: ObservableObject {
    
    private let mobileSDK: MobileSDK
    
    init(mobileSDK: MobileSDK = MobileSDK.shared) {
        self.mobileSDK = mobileSDK

        initialiseMobileSDK()
    }

    private func initialiseMobileSDK() {
        let lightThemeColors = Theme.Colors(
            primary: <#T##Color#>,
            onPrimary: <#T##Color#>,
            text: <#T##Color#>,
            success: <#T##Color#>,
            error: <#T##Color#>,
            background: <#T##Color#>,
            border: <#T##Color#>,
            placeholder: <#T##Color#>)
        let theme = Theme(lighThemeColorst: lightThemeColors, darkThemeColors: <#T##Theme.Colors.Dark#>)
        theme.colors


        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox)
        case .staging: config = MobileSDKConfig(environment: .staging)
        }

        mobileSDK.configureMobileSDK(config: config)
        mobileSDK.printCurrentEnvironment()

        
    }
    
}
