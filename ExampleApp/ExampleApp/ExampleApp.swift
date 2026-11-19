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
        #if DEBUG
        crashIfAsked()
        #endif
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

    #if DEBUG
    /// Debug builds only: `EXAMPLE_APP_TEST_CRASH=true` raises an exception from app code on the main thread 3 s after
    /// launch, the same app crash as the triggers screen's, from a scheme variable. A non-nil reason: CoreFoundation
    /// crashes on a nil one.
    private func crashIfAsked() {
        guard ProcessInfo.processInfo.environment["EXAMPLE_APP_TEST_CRASH"] == "true" else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSException(name: NSExceptionName("ExampleAppTestCrash"), reason: "test", userInfo: nil).raise()
        }
    }
    #endif
}
