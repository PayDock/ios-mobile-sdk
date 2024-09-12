//
//  Standalone3DSVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 29.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

@MainActor
class Standalone3DSVM: NSObject, ObservableObject {

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

    func getValutToken() {
        Task {
            let req = TokeniseCardDetailsReq(
                gatewayId: ProjectEnvironment.shared.getStandalone3dsGatewayId() ?? "",
                cardName: "Test Card",
                cardNumber: "4100000000005000",
                expireMonth: "08",
                expireYear: "25",
                cardCcv: "123")
            do {
                let token = try await walletService.createVaultToken(request: req)
                create3dsToken(vaultToken: token)
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
                    service_id: ProjectEnvironment.shared.getStandalone3dsGatewayId() ?? "",
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
                    self.token3DS = token3DS ?? ""
                    self.showWebView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.showWebView = false
                    self.alertMessage = "3DS failed!"
                    self.showAlert = true
                }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showAlert = true
            }
        case .chargeAuthReject: break
        case .error:
            showWebView = false
            alertMessage = "3DS failed!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showAlert = true
            }
        }
    }

}
