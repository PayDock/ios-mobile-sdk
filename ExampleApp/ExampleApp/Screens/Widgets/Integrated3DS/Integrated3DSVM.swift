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

    private(set) var token3DS = ""
    @Published var showWebView = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func tokeniseCardDetails() {
        Task {
            let req = TokeniseCardDetailsReq(
                gatewayId: "657045c00b76c9392bf5e36d",
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
                DispatchQueue.main.async {
                    self.token3DS = token3DS ?? ""
                    self.showWebView = true
                }
            } catch {
                print(error)
            }
        }
    }

    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }

    func handle3dsEvent(_ event: ThreeDSResult) {
        switch event.event {
        case .chargeAuthChallenge: break
        case .chargeAuthDecoupled: break
        case .chargeAuthInfo: break
        case .chargeAuthSuccess:
            showWebView = false
            alertMessage = event.charge3dsId
        case .error, .chargeAuthReject:
            showWebView = false
            alertMessage = "3DS failed!"
        }
    }

}
