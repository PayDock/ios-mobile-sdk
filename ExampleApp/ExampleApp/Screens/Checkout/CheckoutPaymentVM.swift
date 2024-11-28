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

    @Published var show3dsWebView = false
    @Published var selectedMethod: PaymentMethod = .card
    @Published var showAlert = false
    @Published var isLoading = false
    
    @Published var showMastercardWebView = false

    var alertTitle = ""
    var alertMessage = ""
    var widgetOptions: WidgetOptions?

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        self.widgetOptions = WidgetOptions(state: .none)
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
                let request = createWalletChargeRequest(gatewayId: applePayGatewayId, walletType: "apple")
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                let applePayRequest = self.getApplePayRequest(walletToken: token)
                completion(applePayRequest)
            } catch {
                showAlert(title: .error, message: "Error fetching wallet token!")
            }
        }
    }

    /// Initializes wallet charge when paying through Afterpay
    func initializeAfterpayWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: "123 Test Street", addressPostcode: "BN3 5SL", gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "", walletType: nil)

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "David",
                lastName: "Cameron",
                email: "david.cameron@paydock.com",
                phone: "+1234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeReq.MetaData(
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
                DispatchQueue.main.async {
                    completion(token)
                }
            } catch {
                print("ERROR: Error fetching wallet token!")
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
        
        let metaData = InitialiseWalletChargeReq.MetaData(
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
        widgetOptions?.setState(.disabled)

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
        let request = Integrated3DSVaultReq(amount: "5.50", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken, gatewayId: threeDSGatewayId)), _3ds: .init(browserDetails: .init()))
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
                self.show3dsWebView = true
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
                self.show3dsWebView = false
                self.captureCharge()
            case .chargeAuthReject: break
            case .error:
                self.show3dsWebView = false
                self.showAlert(title: .error, message: "3DS failed!")
            }
        }
    }

    /// Captures the charge as the final step in the payment flow
    private func captureCharge() {
        Task {
            let request = CaptureChargeReq(amount: "5.50", currency: "AUD", customer: .init(paymentSource: .init(vaultToken: vaultToken, gatewayId: threeDSGatewayId)))
            do {
                let result = try await walletService.captureCharge(request: request)
                // Ensure UI updates are performed on the main thread
                await MainActor.run {
                    isLoading = false
                    widgetOptions?.setState(.none)
                    showAlert(title: .success, message: "\(result.amount) \(result.currency) successfully charged!")
                }
            } catch {
                // Ensure UI updates are performed on the main thread
                await MainActor.run {
                    isLoading = false
                    widgetOptions?.setState(.none)
                }
            }
        }
    }
}

// MARK: - Afterpay

extension CheckoutPaymentVM {

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let theme = AfterpaySdkConfig.ButtonTheme(buttonType: .payNow, colorScheme: .static(.blackOnMint))
        let config = AfterpaySdkConfig.AfterpayConfiguration(minimumAmount: "1.0", maximumAmount: "100.0", currency: "AUD", language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions()
        return AfterpaySdkConfig(buttonTheme: theme, config: config, environment: .sandbox, options: options)
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
        return ShippingOptionUpdate(id: "Standard", shippingAmount: Money(amount: "5.0", currency: "AUD"), orderAmount: Money(amount: "10.0", currency: "AUD"))
    }
    
}

// MARK: - Mastercard SRC

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
        case afterpay
        case mastercard
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
