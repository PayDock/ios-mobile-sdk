//
//  Standalone3DSVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 29.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class Standalone3DSVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private(set) var token3DS = ""
    @Published var showWebView = false
    weak var paydockDelegate: PayDockDelegate?

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func getValutToken() {
        Task {
            let req = TokeniseCardDetailsReq(
                gatewayId: "65283088143e65d1f4166f99",
                cardName: "Carlie Kuvalis",
                cardNumber: "2223000000000007",
                expireMonth: "08",
                expireYear: "29",
                cardCcv: "123")

            do {
                let token = try await walletService.createVaultToken(request: req)
                create3dsToken(vaultToken: token)
                print(token)
            } catch {
                print(error)
            }
        }
    }

    private func create3dsToken(vaultToken: String) {
        Task {
            let request = Standalone3DSReq(
                amount: "10",
                currency: "AUD",
                reference: UUID().uuidString,
                customer: .init(paymentSource: .init(token: vaultToken)),
                data: .init(
                    service_id: "65283088143e65d1f4166f99",
                    authentication: .init(
                        type: "01",
                        date: "2023-06-01T13:00:00.521Z",
                        version: "2.2.0",
                        customer: .init(
                            created: "2023-05-31T13:06:05.521Z",
                            updated: "2023-05-31T13:06:05.521Z",
                            credsUpdated: "2023-05-31T13:06:05.521Z",
                            suspicious: false,
                            source: .init(
                                created: "2023-05-31T13:06:05.521Z",
                                attempts: ["2023-05-31T13:06:05.521Z"],
                                cardType: "02"
                            )
                        )
                    )
                )
            )
            do {
                let token3DS = try await walletService.createStandalone3DSToken(request: request)
                DispatchQueue.main.async {
                    self.token3DS = token3DS
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

}

// MARK: - PayDockDelegate

extension Standalone3DSVM: PayDockDelegate {
    func didLoad() {
        print("---Did Load")
    }

    func didSubmit() {
        print("---Did Submit")
    }

    func didFinish() {
        print("---Did Finish")
    }

    func onValidation() {
        print("---On Validation")
    }

    func onValidationFail() {
        print("---Validation Failed")
    }

    func onSystemError() {
        print("---System Error")
    }

    func metaDidChange() {
        print("---Meta change")
    }

    func onResize() {
        print("---Did resize")
    }
}
