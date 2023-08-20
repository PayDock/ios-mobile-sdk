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

    public func printCurrentEnvironment() {
        guard let config = config else {
            print("No environment set!")
            return
        }
        print(config.environment)

        Task {
            let req = TokeniseCardDetailsReq(gatewayId: "5cbede1f151b842653e987be", cardName: "Wanda Mertz", cardNumber: "4242424242424242", expireMonth: "09", expireYear: "21", cardCcv: "123")
            do {
                let token = try await cardService.createToken(tokeniseCardDetailsReq: req)
            } catch {
                print(error)
            }

        }
    }

    private func registerFonts() {
        fontRegistration.registerAllFonts()
    }

}
