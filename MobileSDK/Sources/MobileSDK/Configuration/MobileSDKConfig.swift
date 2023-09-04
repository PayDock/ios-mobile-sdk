//
//  MobileSDKConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

public struct MobileSDKConfig {

    var environment: SDKEnvironment

    public init(environment: SDKEnvironment,
                theme: Theme) {
        self.environment = environment

        setup()
    }

    private func setup() {

    }

}
