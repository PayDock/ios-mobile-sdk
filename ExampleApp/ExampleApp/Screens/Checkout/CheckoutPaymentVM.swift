//
//  CheckoutPaymentVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import Afterpay
import NetworkingLib

@MainActor
class CheckoutPaymentVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    let applePayGatewayId = ProjectEnvironment.shared.getApplePayGatewayId() ?? ""
    let threeDSGatewayId = ProjectEnvironment.shared.getIntegrated3dsGatewayId() ?? ""
    let payPalGatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""

    private var cardToken = ""
    private var vaultToken = ""
    private(set) var token3DS = ""
    private var colesPayChargeId = ""

    @Published var show3dsWebView = false
    @Published var selectedMethod: PaymentMethod = .card
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var showMastercardWebView = false

    var alertTitle = ""
    var alertMessage = ""
    var viewState: ViewState?

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        self.viewState = ViewState(state: .none)
    }
}

// MARK: - Wallet

extension CheckoutPaymentVM {
    /// Initializes wallet charge when paying through PayPal
    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            do {
                let request = createWalletChargeRequest(gatewayId: payPalGatewayId, walletType: nil)
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                completion(.success(.init(token: token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
                viewState?.setState(.none)
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    /// Initializes wallet charge when paying through ApplePay
    func initializeWalletCharge(completion: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) {
        Task {
            do {
                isLoading = true
                let request = createWalletChargeRequest(gatewayId: applePayGatewayId, walletType: "apple")
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                let applePayRequestResult = self.getApplePayRequestResult(walletToken: token)
                completion(.success(ApplePayRequestResult(request: applePayRequestResult.request, token: applePayRequestResult.token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
                viewState?.setState(.none)
            } catch {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    /// Initializes wallet charge when paying through Afterpay
    func initializeAfterpayWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: "123 Test Street",
                addressPostcode: "BN3 5SL",
                gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "",
                walletType: nil)

            let customer = InitialiseWalletChargeCustomer(
                firstName: "David",
                lastName: "Cameron",
                email: "david.cameron@paydock.com",
                phone: "+1234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeMetaData(
                storeName: "Tom Taylor Ltd.",
                merchantName: "Tom's store",
                storeId: "1234556",
                successUrl: "https://paydock-integration.netlify.app/success",
                errorUrl: "https://paydock-integration.netlify.app/error")

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: 5,
                currency: "AUD",
                reference: UUID().uuidString,
                description: "Test transaction for Afterpay",
                meta: metaData)

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                completion(.success(.init(token: token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
                viewState?.setState(.none)
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    /// Helper method that creates ApplePay request
    private func getApplePayRequestResult(walletToken: String) -> ApplePayRequestResult {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: 5.50,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: ProjectEnvironment.shared.getMerchantId() ?? "")

        return ApplePayRequestResult(request: paymentRequest, token: walletToken)
    }

    /// Helper method that creates Wallet Charge request
    private func createWalletChargeRequest(gatewayId: String, walletType: String?) -> InitialiseWalletChargeReq {
        let paymentSource = InitialiseWalletChargePaymentSource(
            addressLine1: nil,
            addressPostcode: nil,
            gatewayId: gatewayId,
            walletType: walletType)

        let customer = InitialiseWalletChargeCustomer(
            firstName: "Tom",
            lastName: "Taylor",
            email: "novaba9346@hondabbs.com",
            phone: "+11234567890",
            paymentSource: paymentSource)

        let metaData = InitialiseWalletChargeMetaData(
            storeName: "Tom Taylor Ltd.",
            merchantName: "Tom's store",
            storeId: "1234556",
            successUrl: nil,
            errorUrl: nil)

        let initializeWalletChargeReq = InitialiseWalletChargeReq(
            customer: customer,
            amount: 10,
            currency: "AUD",
            reference: UUID().uuidString,
            description: "Test purchase",
            meta: metaData)

        return initializeWalletChargeReq
    }
}

// MARK: - Card Payment

extension CheckoutPaymentVM {

    /// Initialized card payment using the tokenised card details
    func payWithCard(_ token: String) {
        self.cardToken = token
        guard !cardToken.isEmpty else { return }
        isLoading = true
        viewState?.setState(.disabled)

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
        let request = Integrated3DSVaultReq(
            amount: "5.50",
            currency: "AUD",
            customer: .init(paymentSource: .init(vaultToken: vaultToken, gatewayId: threeDSGatewayId)),
            threeDS: .init(browserDetails: .init()))
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
        case .notSupported: captureCharge(threeDsId: response.resource.data.threeDS.id ?? "")
        case .pending:
            DispatchQueue.main.async {
                self.isLoading = false
                self.viewState?.setState(.none)
                self.token3DS = response.resource.data.threeDS.token ?? ""
                self.show3dsWebView = true
            }
        case .none:
            showAlert(title: .error, message: "Error getting 3DS auth status!")
        }
    }

    /// Handles the outcome of integrated 3DS WebView check
    func handle3dsEvent(_ event: Integrated3DSResult) {
        DispatchQueue.main.async {
            switch event.event {
            case .chargeAuth: break
            case .additionalDataCollectSuccess: break
            case .chargeAuthReject:
                self.show3dsWebView = false
                self.showAlert(title: .error, message: "3DS auth rejected!")
            case .additionalDataCollectReject:
                self.show3dsWebView = false
                self.showAlert(title: .error, message: "3DS additional data rejected!")
            case .chargeAuthCancelled:
                self.show3dsWebView = false
                self.showAlert(title: .error, message: "3DS cancelled!")
            case .chargeAuthSuccess:
                self.show3dsWebView = false
                self.captureCharge(threeDsId: event.charge3dsId)
            }
        }
    }

    /// Captures the charge as the final step in the payment flow
    private func captureCharge(threeDsId: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        viewState?.setState(.disabled)
        Task {
            let request = CaptureChargeReq(
                amount: "5.50",
                currency: "AUD",
                reference: UUID().uuidString,
                description: "Test Payment",
                threeDS: .init(id3DS: threeDsId))

            do {
                let result = try await walletService.captureCharge(request: request)
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showAlert(title: .success, message: "\(result.amount) \(result.currency) successfully charged!")
                }

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                viewState?.setState(.none)
                showAlert(title: .error, message: errorResponse.error?.message ?? "Error creating a charge")

            } catch {
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showAlert(title: .error, message: "Error creating a charge!")
                }
            }
        }
    }
}

// MARK: - PayPal

extension CheckoutPaymentVM {

    func getPayPalConfig() -> PayPalWidgetConfig {
        let accessToken = ProjectEnvironment.shared.getWidgetAccessToken()
        let gatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
        let config = PayPalWidgetConfig(accessToken: accessToken, gatewayId: gatewayId)
        return config
    }
}

// MARK: - Afterpay

extension CheckoutPaymentVM {

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let config = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: "1.0",
            maximumAmount: "100.0",
            currency: "AUD",
            language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions()
        return AfterpaySdkConfig(config: config, environment: .sandbox, options: options)
    }

    func getShippingOptions() -> [ShippingOption] {
        let shippingOption1 = ShippingOption(
            id: "Standard",
            name: "Standard",
            description: "",
            shippingAmount: Money(amount: "5.0", currency: "AUD"),
            orderAmount: Money(amount: "10.0", currency: "AUD"))

        let shippingOption2 = ShippingOption(
            id: "Standard",
            name: "Standard",
            description: "",
            shippingAmount: Money(amount: "2.0", currency: "AUD"),
            orderAmount: Money(amount: "10.0", currency: "AUD"))

        return [shippingOption1, shippingOption2]
    }

    func getShippingOptionUpdate() -> ShippingOptionUpdate {
        return ShippingOptionUpdate(
            id: "Standard",
            shippingAmount: Money(amount: "5.0", currency: "AUD"),
            orderAmount: Money(amount: "10.0", currency: "AUD"))
    }

}

// MARK: - Mastercard ClickToPay

extension CheckoutPaymentVM {

    func handleMastercardResult(_ result: ClickToPayResult) {
        switch result.event {
        case .checkoutCompleted:
            showMastercardWebView = false
            payWithCard(result.mastercardToken)

        case .checkoutReady:
            print("Checkout ready")

        case .checkoutError:
            showMastercardWebView = false
            alertTitle = "Checkout failure"
            alertMessage = "Please try again."
            showAlert = true
        }
    }

}

// MARK: - ColesPay

extension CheckoutPaymentVM {

    func initializeWalletChargeColesPay(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        viewState?.setState(.disabled)
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: "123 Test Street",
                addressPostcode: "BN3 5SL",
                gatewayId: ProjectEnvironment.shared.getColesPayGatewayId() ?? "",
                walletType: nil)

            let customer = InitialiseWalletChargeCustomer(
                firstName: "Wanda",
                lastName: "Mertz",
                email: "wanda.mertz@example.com",
                phone: "+1234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeMetaData(
                storeName: "Tom Taylor Ltd.",
                merchantName: "Tom's store",
                storeId: "1234556",
                successUrl: nil,
                errorUrl: nil)

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: 5,
                currency: "AUD",
                reference: "reference1234",
                description: "Test transaction for Coles Pay",
                meta: metaData)

            do {
                let response = try await walletService.initialiseColesPayWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                let token = response.token
                self.colesPayChargeId = response.charge.id
                DispatchQueue.main.async {
                    completion(.success(WalletTokenResult(token: token)))
                    self.viewState?.setState(.none)
                }
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
                viewState?.setState(.none)
            } catch let RequestError.connectionError(urlError) {
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
                viewState?.setState(.none)
            } catch {
                completion(.failure(.initialisingWalletToken(reason: error.localizedDescription)))
                viewState?.setState(.none)
            }
        }
    }

    func handleError(error: ColesPayError) {
        showAlert(title: .error, message: error.customMessage)
    }

    func handleSuccess() {
        captureColesPayCharge()
    }

    private func captureColesPayCharge() {
        isLoading = true
        Task {
            do {
                // For Coles Pay - a delay is needed as order is still processing with hook that needs to be fired to finish payment setup
                // If this hook has not completed, this charge will fail with error "Charge in invalid state for capture".
                // Improvement to add polling of charge state and when in correct state then finish the charge.
                try await Task.sleep(for: .seconds(2))
                let res = try await walletService.captureChargeColesPay(chargeId: colesPayChargeId)
                isLoading = false
                showAlert(title: .success, message: "Charge successful: \(res.amount) \(res.currency)")

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                showAlert(title: .error, message: errorResponse.error?.message ?? "Error creating ColesPay charge")

            } catch {
                isLoading = false
                showAlert(title: .error, message: "Error creating ColesPay charge")
            }
        }
    }

}

// MARK: - Helpers

extension CheckoutPaymentVM {

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
        case afterpay
        case mastercard
        case colesPay
    }
}

extension CheckoutPaymentVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}
