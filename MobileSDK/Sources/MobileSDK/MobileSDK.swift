//
//  MobileSDK.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation

public class MobileSDK {

    public static let shared = MobileSDK()
    private(set) var config: MobileSDKConfig?
    private let fontRegistration: FontRegistration

    // MARK: - Initialisation

    private init(fontRegistration: FontRegistration = FontRegistration()) {
        self.fontRegistration = fontRegistration

        setup()
    }

    private func setup() {
        fontRegistration.registerAllFonts()
    }

    public func configureMobileSDK(config: MobileSDKConfig) {
        self.config = config
    }

}
