//
//  MobileSDK.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation

public class MobileSDK {

    public static let shared = MobileSDK()
    var config: MobileSDKConfig?

    // MARK: - Initialisation

    private init() { }

    public func configureMobileSDK(config: MobileSDKConfig) {
        self.config = config
    }

    public func printCurrentEnvironment() {
        guard let config = config else {
            print("No environment set!")
            return
        }
        print(config.environment)
    }

}
