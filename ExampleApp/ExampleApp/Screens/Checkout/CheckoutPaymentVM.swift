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
    let gatewayId = ProjectEnvironment.shared.getApplePayGatewayId() ?? ""
    let payPalGatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
    
    private var cardToken = ""
    private var vaultToken = ""
    private(set) var token3DS = ""

    @Published var showWebView = false
    @Published var selectedMethod: PaymentMethod = .card
    @Published var showAlert = false
    @Published var isLoading = false
    var alertTitle = ""
    var alertMessage = ""

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
    }
}

// MARK: - Wallet

extension CheckoutPaymentVM {
    /// Initializes wallet charge when paying through PayPal
    func initializeWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            do {
                let request = createWalletChargeRequest(gatewayId: payPalGatewayId, walletType: nil)
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                completion(token)
            } catch {
                showAlert(title: .error, message: "Error fetching wallet token!")
            }
        }
    }

    /// Initializes wallet charge when paying through ApplePay
    func initializeWalletCharge(completion: @escaping (ApplePayRequest) -> Void) {
        Task {
            do {
                let request = createWalletChargeRequest(gatewayId: gatewayId, walletType: "apple")
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                let applePayRequest = self.getApplePayRequest(walletToken: token)
                completion(applePayRequest)
            } catch {
                showAlert(title: .error, message: "Error fetching wallet token!")
            }
        }
    }

    /// Helper method that creates ApplePay request
    private func getApplePayRequest(walletToken: String) -> ApplePayRequest {
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

    /// Helper method that creates Wallet Charge request
    private func createWalletChargeRequest(gatewayId: String, walletType: String?) -> InitialiseWalletChargeReq {
        let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: nil, addressPostcode: nil, gatewayId: gatewayId, walletType: walletType )
        let customer = InitialiseWalletChargeReq.Customer(
            firstName: "Tom",
            lastName: "Taylor",
            email: "novaba9346@hondabbs.com",
            phone: "+11234567890",
            paymentSource: paymentSource)
        let metaData = InitialiseWalletChargeReq.MetaData(storeName: "Tom Taylor Ltd.", merchantName: "Tom's store", storeId: "1234556")
        let initializeWalletChargeReq = InitialiseWalletChargeReq(
            customer: customer,
            amount: 10,
            currency: "USD",
            reference: UUID().uuidString,
            description: "Test purchase",
            meta: metaData)

        return initializeWalletChargeReq
    }
}

// MARK: - Card Payment

extension CheckoutPaymentVM {

    func saveCardToken(_ token: String) {
        self.cardToken = token
    }

    /// Initialized card payment using the tokenised card details
    func payWithCard() {
        guard !cardToken.isEmpty else { return }
        isLoading = true

        let request = ConvertToVaultTokenReq(token: cardToken, vaultType: "session")
        Task {
            do {
                let vaultToken = try await walletService.convertCardTokenToVaultToken(request: request)
                self.vaultToken = vaultToken
                attempt3dsTokenCreation()
            } catch {
                showAlert(title: .error, message: "Error converting to vault token!")
            }
        }
    }

    /// Attempts to create 3DS token and receive 3DS auth status
    private func attempt3dsTokenCreation() {
        let request = Integrated3DSVaultReq(amount: "5.50", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken, gayewayId: gatewayId)), _3ds: .init(browserDetails: .init()))
        Task {
            do {
                let response = try await walletService.createIntegrated3DSVaultToken(request: request)
                handleAuthStatus(response)
            } catch {
                showAlert(title: .error, message: "Error creating integrated 3DS token!")
            }
        }
    }

    /// Based on 3DS auth status selects the appropriate flow
    private func handleAuthStatus(_ response: Integrated3DSRes) {
        switch response.authStatus {
        case .notSupported: captureCharge()
        case .pending:
            DispatchQueue.main.async {
                self.token3DS = response.resource.data.threeDS.token ?? ""
                self.showWebView = true
            }
        case .none:
            showAlert(title: .error, message: "Error getting 3DS auth status!")
        }
    }

    /// Handles the outcome of 3DS WebView check
    func handle3dsEvent(_ event: ThreeDSResult) {
        DispatchQueue.main.async {
            switch event.event {
            case .chargeAuthChallenge: break
            case .chargeAuthDecoupled: break
            case .chargeAuthInfo: break
            case .chargeAuthSuccess:
                self.showWebView = false
                self.captureCharge()
            case .chargeAuthReject: break
            case .error:
                self.showWebView = false
                self.showAlert(title: .error, message: "3DS failed!")
            }
        }
    }

    /// Captures the charge as the final step in the payment flow
    private func captureCharge() {
        Task {
            let request = CaptureChargeReq(amount: "5.50", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken)))
            do {
                let result = try await walletService.captureCharge(request: request)
                isLoading = false
                showAlert(title: .success, message: "\(result.amount) \(result.currency) successfully charged!")
            } catch {
                isLoading = false
            }
        }
    }
}

// MARK: - Helpers

extension CheckoutPaymentVM {

    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }

    private func showAlert(title: AlertTitle, message: String) {
        alertTitle = title.rawValue
        alertMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlert = true
        }
    }

    enum AlertTitle: String {
        case success = "Success"
        case error = "Error"
    }

    enum PaymentMethod {
        case card
        case applePay
        case payPal
    }
}
