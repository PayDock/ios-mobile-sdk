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
    private let exampleService: ExampleService

    // MARK: - Initialisation

    private init(exampleService: ExampleService = ExampleServiceImpl()) {
        self.exampleService = exampleService
    }

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
