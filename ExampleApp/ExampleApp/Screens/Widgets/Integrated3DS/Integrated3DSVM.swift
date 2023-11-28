//
//  Integrated3DSVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class Integrated3DSVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var walletToken = ""
    @Published var payPalButtonEnabled = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func tokeniseCardDetails() {
        Task {
            let req = TokeniseCardDetailsReq(
                gatewayId: "65144f9bfee65245ecd2db17",
                cardName: "Carlie Kuvalis",
                cardNumber: "2223000000000007",
                expireMonth: "08",
                expireYear: "29",
                cardCcv: "123")

            do {
                let token = try await walletService.createCardToken(tokeniseCardDetailsReq: req)
                create3dsToken(cardToken: token)
                print(token)
            } catch {
                print(error)
            }
        }
    }

    private func create3dsToken(cardToken: String) {
        Task {
            let req = Integrated3DSReq(amount: "10", currency: "AUD", _3ds: .init(browserDetails: .init()), token: cardToken)

            do {
                let token3DS = try await walletService.createIntegrated3DSToken(request: req)
                print(token3DS)
            } catch {
                print(error)
            }
        }
    }

}
