//
//  EnhancedCheckoutVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 30.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import Afterpay
import NetworkingLib

@MainActor
class EnhancedCheckoutVM: ObservableObject {

    // MARK: - Dependencies
    private let walletService: WalletService
    private let cartManager = CartManager.shared
    private var colesPayChargeId = ""

    // MARK: - Published Properties

    // Customer Information
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""

    // Shipping Address
    @Published var address = ""
    @Published var addressLine2 = ""
    @Published var city = ""
    @Published var state = ""
    @Published var postalCode = ""
    @Published var country = ""
    @Published var selectedShippingAddressId: String?

    // Billing Information
    @Published var useShippingAsBilling = true
    @Published var billingAddress = ""
    @Published var billingAddressLine2 = ""
    @Published var billingCity = ""
    @Published var billingState = ""
    @Published var billingPostalCode = ""
    @Published var billingCountry = ""
    @Published var selectedBillingAddressId: String?

    // Payment
    @Published var selectedPaymentMethod: PaymentMethod?
    @Published var cardToken = ""
    @Published var payPalToken = ""
    @Published var afterPayToken = ""
    @Published var mastercardToken = ""
    @Published var colesPayToken = ""

    // UI State
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var orderCompleted = false
    @Published var showMastercardWebView = false

    var alertTitle = ""
    var alertMessage = ""
    var viewState: ViewState?

    // MARK: - Computed Properties

    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var formattedShippingAddress: String {
        var components: [String] = []

        if !address.isEmpty {
            components.append(address)
        }
        if !addressLine2.isEmpty {
            components.append(addressLine2)
        }
        if !city.isEmpty && !state.isEmpty {
            components.append("\(city), \(state)")
        } else if !city.isEmpty {
            components.append(city)
        }
        if !postalCode.isEmpty {
            components.append(postalCode)
        }
        if !country.isEmpty {
            components.append(country)
        }

        return components.joined(separator: "\n")
    }

    var formattedBillingAddress: String {
        var components: [String] = []

        if !billingAddress.isEmpty {
            components.append(billingAddress)
        }
        if !billingAddressLine2.isEmpty {
            components.append(billingAddressLine2)
        }
        if !billingCity.isEmpty && !billingState.isEmpty {
            components.append("\(billingCity), \(billingState)")
        } else if !billingCity.isEmpty {
            components.append(billingCity)
        }
        if !billingPostalCode.isEmpty {
            components.append(billingPostalCode)
        }
        if !billingCountry.isEmpty {
            components.append(billingCountry)
        }

        return components.joined(separator: "\n")
    }

    var shippingAddressComplete: Bool {
        return !address.isEmpty && !city.isEmpty && !postalCode.isEmpty && !country.isEmpty
    }

    var billingAddressComplete: Bool {
        return !billingAddress.isEmpty && !billingCity.isEmpty && !billingPostalCode.isEmpty && !billingCountry.isEmpty
    }

    var isInformationComplete: Bool {
        let basicInfoComplete = !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        isEmailValid(email)

        let shippingComplete = selectedShippingAddressId != nil || shippingAddressComplete

        let billingComplete = useShippingAsBilling ||
        selectedBillingAddressId != nil ||
        billingAddressComplete

        return basicInfoComplete && shippingComplete && billingComplete
    }

    // MARK: - Private Properties
    private var vaultToken = ""
    private var token3DS = ""

    // MARK: - Gateway IDs
    let applePayGatewayId = ProjectEnvironment.shared.getApplePayGatewayId() ?? ""
    let threeDSGatewayId = ProjectEnvironment.shared.getIntegrated3dsGatewayId() ?? ""
    let payPalGatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""

    // MARK: - Initialization

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        self.viewState = ViewState(state: .none)
    }

    // MARK: - Validation

    private func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // MARK: - Order Processing

    func placeOrder() {
        isLoading = true

        // Simulate order processing with payment method handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.orderCompleted = true
            self.alertTitle = "Order Successful!"

            var paymentMethodText = ""
            if let method = self.selectedPaymentMethod {
                paymentMethodText = " Payment via \(method.displayName) was successful."
            }

            self.alertMessage = """
                Thank you \(self.firstName)! Your order has been placed successfully.\
                \(paymentMethodText) You will receive a confirmation email shortly.
            """
            self.showAlert = true
        }
    }

    // MARK: - Apple Pay

    func initializeApplePayCharge(completion: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) {
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
            } catch {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func handleApplePayResult(_ result: Result<ChargeResponse, ApplePayError>) {
        isLoading = false
        switch result {
        case .success(let chargeResponse):
            alertTitle = "Payment Successful"
            alertMessage = "Apple Pay transaction completed successfully."
        case .failure(let error):
            alertTitle = "Payment Failed"
            alertMessage = error.customMessage
            showAlert = true
        }
    }

    // MARK: - PayPal

    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            do {
                let request = createWalletChargeRequest(gatewayId: payPalGatewayId, walletType: nil)
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: request)
                completion(.success(.init(token: token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func handlePayPalResult(_ result: Result<ChargeResponse, PayPalError>) {
        switch result {
        case .success(let chargeResponse):
            alertTitle = "Payment Successful"
            alertMessage = "PayPal transaction completed successfully."
        case .failure(let error):
            alertTitle = "Payment Failed"
            alertMessage = error.customMessage
            showAlert = true
        }
    }

    // MARK: - AfterPay

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let config = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: "1.0",
            maximumAmount: "100.0",
            currency: "AUD",
            language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions()
        return AfterpaySdkConfig(config: config, environment: .sandbox, options: options)
    }

    func initializeAfterpayCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: address,
                addressPostcode: postalCode,
                gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "",
                walletType: nil
            )

            let customer = InitialiseWalletChargeCustomer(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                paymentSource: paymentSource
            )

            let metaData = InitialiseWalletChargeMetaData(
                storeName: "Demo Store",
                merchantName: "Demo Merchant",
                storeId: "demo123",
                successUrl: "https://demo.com/success",
                errorUrl: "https://demo.com/error"
            )

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: Decimal(cartManager.total),
                currency: "AUD",
                reference: UUID().uuidString,
                description: "Order from Demo Store",
                meta: metaData
            )

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                completion(.success(.init(token: token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func handleAfterpayResult(_ result: Result<ChargeResponse, AfterpayError>) {
        switch result {
        case .success:
            alertTitle = "Payment Successful"
            alertMessage = "Afterpay transaction completed successfully."
        case .failure:
            alertTitle = "Payment Failed"
            alertMessage = "Afterpay transaction failed."
            showAlert = true
        }
    }

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
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
                viewState?.setState(.none)
            }
        }
    }

    func handleError(error: ColesPayError) {

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
                //                showAlert(title: .success, message: "Charge successful: \(res.amount) \(res.currency)")
            } catch {
                isLoading = false
                //                showAlert(title: .error, message: error.localizedDescription)
            }
        }
    }

    // MARK: - Helper Methods

    private func createWalletChargeRequest(gatewayId: String, walletType: String?) -> InitialiseWalletChargeReq {
        let paymentSource = InitialiseWalletChargePaymentSource(
            addressLine1: address,
            addressPostcode: postalCode,
            gatewayId: gatewayId,
            walletType: walletType
        )

        let customer = InitialiseWalletChargeCustomer(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            paymentSource: paymentSource
        )

        let metaData = InitialiseWalletChargeMetaData(
            storeName: "Demo Store",
            merchantName: "Demo Merchant",
            storeId: "demo123",
            successUrl: "https://demo.com/success",
            errorUrl: "https://demo.com/error"
        )

        return InitialiseWalletChargeReq(
            customer: customer,
            amount: Decimal(cartManager.total),
            currency: "AUD",
            reference: UUID().uuidString,
            description: "Order from Demo Store",
            meta: metaData
        )
    }

    private func getApplePayRequestResult(walletToken: String) -> ApplePayRequestResult {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: Decimal(cartManager.total),
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: ProjectEnvironment.shared.getMerchantId() ?? "")

        return ApplePayRequestResult(request: paymentRequest, token: walletToken)
    }
}

// MARK: - LoadingDelegate

extension EnhancedCheckoutVM: WidgetLoadingDelegate {
    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}
