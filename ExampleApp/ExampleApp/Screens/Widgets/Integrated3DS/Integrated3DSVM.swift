//
//  Integrated3DSVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

@MainActor
class Integrated3DSVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private(set) var token3DS = ""
    @Published var showWebView = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func tokeniseCardDetails() {
        isLoading = true
        Task {
            let req = TokeniseCardDetailsReq(
                gatewayId: ProjectEnvironment.shared.getIntegrated3dsGatewayId() ?? "",
                cardName: "Carlie Kuvalis",
                cardNumber: "2223000000000007",
                expireMonth: "08",
                expireYear: "29",
                cardCcv: "123")

            do {
                let token = try await walletService.createCardToken(tokeniseCardDetailsReq: req)
                create3dsToken(cardToken: token)
            } catch {
                alertMessage = "Error tokenising card details!"
                isLoading = false
                showAlert = true
            }
        }
    }

    private func create3dsToken(cardToken: String) {
        Task {
            let req = Integrated3DSReq(amount: "10", currency: "AUD", _3ds: .init(browserDetails: .init()), token: cardToken)
            do {
                let token3DS = try await walletService.createIntegrated3DSToken(request: req)
                    self.isLoading = false
                    self.token3DS = token3DS ?? ""
                    self.showWebView = true
            } catch {
                    self.isLoading = false
                    self.showWebView = false
                    self.alertMessage = "Error tokenising card details!"
                    self.showAlert = true
            }
        }
    }

    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }
    
    func handle3dsEvent(_ event: Integrated3DSResult) {
        switch event.event {
        case .chargeAuth: break
        case .additionalDataCollectSuccess: break
        case .chargeAuthReject:
            self.showWebView = false
            alertMessage = "3DS auth rejected!"
            
        case .additionalDataCollectReject:
            self.showWebView = false
            alertMessage = "3DS additional data rejected!"
            
        case .chargeAuthCancelled:
            self.showWebView = false
            alertMessage = "3DS cancelled!"
            
        case .chargeAuthSuccess:
            self.showWebView = false
            alertMessage = event.charge3dsId
        }
    }
    
    func handleFailure(error: Integrated3DSError) {
        showWebView = false
        alertMessage = error.customMessage
        showAlert = true
    }
}
