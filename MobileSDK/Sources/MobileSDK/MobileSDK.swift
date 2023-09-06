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
    private let cardService: CardService
    private let fontRegistration: FontRegistration

    // MARK: - Initialisation

    private init(cardService: CardService = CardServiceImpl(),
                 fontRegistration: FontRegistration = FontRegistration()) {
        self.cardService = cardService
        self.fontRegistration = fontRegistration
    }

    public func configureMobileSDK(config: MobileSDKConfig) {
        self.config = config
        self.registerFonts()
    }

    private func registerFonts() {
        fontRegistration.registerAllFonts()
    }

}
