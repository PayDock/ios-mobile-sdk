//
//  WidgetsVM.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
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
        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production, publicKey: ProjectEnvironment.shared.getPublicKey())
        case .sandbox: config = MobileSDKConfig(environment: .sandbox, publicKey: ProjectEnvironment.shared.getPublicKey())
        case .staging: config = MobileSDKConfig(environment: .staging, publicKey: ProjectEnvironment.shared.getPublicKey())
        }

        mobileSDK.configureMobileSDK(config: config)
    }
    
}
