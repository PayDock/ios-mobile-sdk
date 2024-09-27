//
//  ExampleApp.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.07.2023..
//

import SwiftUI
import MobileSDK

@main
struct ExampleApp: App {

    init() {
        setupMobileSDK()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

    private func setupMobileSDK() {
        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox)
        case .staging: config = MobileSDKConfig(environment: .staging)
        }

        MobileSDK.shared.configureMobileSDK(config: config)
    }
}
