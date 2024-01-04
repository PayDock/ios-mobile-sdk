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

    @Published var selectedMethod: PaymentMethod = .card
    private let gatewayId = "657045c00b76c9392bf5e36d"
    private var cardToken = ""
    private(set) var token3DS = ""
    @Published var showWebView = false

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
                print("ERROR: Error fetching wallet token!")
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
                print("ERROR: Error fetching wallet token!")
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
                attempt3dsTokenCreation(vaultToken: vaultToken)
                print(vaultToken)
            } catch {
                print(error)
            }
        }
    }

    private func attempt3dsTokenCreation(vaultToken: String) {
        let request = Integrated3DSVaultReq(amount: "10", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken, gayewayId: gatewayId)), _3ds: .init(browserDetails: .init()))
        Task {
            do {
                let status = try await walletService.createIntegrated3DSVaultToken(request: request)
                handleAuthStatus(status, vaultToken: vaultToken)
            } catch {
                print(error)
            }
        }
    }

    private func handleAuthStatus(_ status: Integrated3DSRes.AuthStatus?, vaultToken: String) {
        switch status {
        case .notSupported: captureCharge(vaultToken: vaultToken)
        case .pending: create3dsToken(vaultToken: vaultToken)
        case .none: break
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
                    service_id: "6478973c43a3a364d9f148a4",
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
                print(error)
            }
        }
    }

    func handle3dsEvent(_ event: ThreeDSResult) {
        switch event.event {
        case .chargeAuthChallenge: break
        case .chargeAuthDecoupled: break
        case .chargeAuthInfo: break
        case .chargeAuthSuccess:
            showWebView = false
//            alertMessage = event.charge3dsId
        case .chargeAuthReject: break
        case .error:
            showWebView = false
//            alertMessage = "3DS failed!"
        }
    }

    private func captureCharge(vaultToken: String) {
        Task {
            let request = CaptureChargeReq(amount: "10", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken)))
            do {
                let result = try await walletService.captureCharge(request: request)
                print(result)
            } catch {
                print(error)
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
