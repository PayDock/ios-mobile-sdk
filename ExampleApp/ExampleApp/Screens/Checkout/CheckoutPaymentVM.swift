//
//  CheckoutPaymentVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class CheckoutPaymentVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties
//    let gatewayId = "656dd1c6b5ae553ab9c4421e"
    let gatewayId = "657045c00b76c9392bf5e36d"
    private var cardToken = ""
    private var vaultToken = ""
    private(set) var token3DS = ""

    @Published var showWebView = false
    @Published var selectedMethod: PaymentMethod = .card
    @Published var showAlert = false
    var alertTitle = ""
    var alertMessage = ""

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
    }

    // MARK: - Wallet

    func initializeWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: createWalletChargeRequest())
                DispatchQueue.main.async {
                    completion(token)
                }
            } catch {
                showAlert = true
                alertTitle = "Error"
                alertMessage = "Error fetching wallet token!"
            }
        }
    }

    func initializeWalletCharge(completion: @escaping (ApplePayRequest) -> Void) {
        Task {
            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: createWalletChargeRequest())
                DispatchQueue.main.async {
                    let applePayRequest = self.getApplePayRequest(walletToken: token)
                    completion(applePayRequest)
                }
            } catch {
                showAlert = true
                alertTitle = "Error"
                alertMessage = "Error fetching wallet token!"
            }
        }
    }

    func getApplePayRequest(walletToken: String) -> ApplePayRequest {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: 5.50,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: "merchant.test-paydock")

        let applePayRequest = ApplePayRequest(
            token: walletToken,
            request: paymentRequest)

        return applePayRequest
    }

    func createWalletChargeRequest() -> InitialiseWalletChargeReq {
        let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(gatewayId: gatewayId)
        let customer = InitialiseWalletChargeReq.Customer(
            firstName: "Tom",
            lastName: "Taylor",
            email: "tom.taylor@tommy.com",
            phone: "+11234567890",
            paymentSource: paymentSource)
        let metaData = InitialiseWalletChargeReq.MetaData(storeName: "Tom Taylor Ltd.", storeId: "1234556")
        let initializeWalletChargeReq = InitialiseWalletChargeReq(
            customer: customer,
            amount: 10,
            currency: "AUD",
            reference: "Test purchase",
            description: "Test purchase",
            meta: metaData)

        return initializeWalletChargeReq
    }

    // MARK: - Card Payment

    func saveCardToken(_ token: String) {
        self.cardToken = token
    }

    func payWithCard() {
        guard !cardToken.isEmpty else { return }

        let request = ConvertToVaultTokenReq(token: cardToken, vaultType: "session")
        Task {
            do {
                let vaultToken = try await walletService.convertCardTokenToVaultToken(request: request)
                self.vaultToken = vaultToken
                attempt3dsTokenCreation()
            } catch {
                showAlert = true
                alertTitle = "Error"
                alertMessage = "Error converting to vault token!"
            }
        }
    }

    private func attempt3dsTokenCreation() {
        let request = Integrated3DSVaultReq(amount: "10", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken, gayewayId: gatewayId)), _3ds: .init(browserDetails: .init()))
        Task {
            do {
                let response = try await walletService.createIntegrated3DSVaultToken(request: request)
                handleAuthStatus(response)
            } catch {
                showAlert = true
                alertTitle = "Error"
                alertMessage = "Error creating integrated 3DS token!"
            }
        }
    }

    private func handleAuthStatus(_ response: Integrated3DSRes) {
        switch response.authStatus {
        case .notSupported: captureCharge()
        case .pending:
            token3DS = response.resource.data.threeDS.token ?? ""
            showWebView = true
        case .none: break
        }
    }

    func handle3dsEvent(_ event: ThreeDSResult) {
        switch event.event {
        case .chargeAuthChallenge: break
        case .chargeAuthDecoupled: break
        case .chargeAuthInfo: break
        case .chargeAuthSuccess:
            showWebView = false
            captureCharge()
        case .chargeAuthReject: break
        case .error:
            showWebView = false
//            alertMessage = "3DS failed!"
        }
    }

    private func captureCharge() {
        Task {
            let request = CaptureChargeReq(amount: "10", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken)))
            do {
                let result = try await walletService.captureCharge(request: request)
                alertTitle = "Success"
                alertMessage = "\(result.amount) \(result.currency) successfully charged!"
                showAlert = true
            } catch {
            }
        }
    }

    enum PaymentMethod {
        case card
        case applePay
        case payPal
    }

    // MARK: - Helpers

    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }

}
