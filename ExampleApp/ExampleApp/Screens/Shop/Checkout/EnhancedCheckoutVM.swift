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
// swiftlint:disable file_length
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
    @Published var shippingFirstName = "" {
        didSet {
            if useShippingAsBilling {
                billingFirstName = shippingFirstName
            }
        }
    }
    @Published var shippingLastName = "" {
        didSet {
            if useShippingAsBilling {
                billingLastName = shippingLastName
            }
        }
    }
    @Published var address = "" {
        didSet {
            if useShippingAsBilling {
                billingAddress = address
            }
        }
    }
    @Published var addressLine2 = "" {
        didSet {
            if useShippingAsBilling {
                billingAddressLine2 = addressLine2
            }
        }
    }
    @Published var city = "" {
        didSet {
            if useShippingAsBilling {
                billingCity = city
            }
        }
    }
    @Published var state = "" {
        didSet {
            if useShippingAsBilling {
                billingState = state
            }
        }
    }
    @Published var postalCode = "" {
        didSet {
            if useShippingAsBilling {
                billingPostalCode = postalCode
            }
        }
    }
    @Published var country = "" {
        didSet {
            if useShippingAsBilling {
                billingCountry = country
            }
        }
    }
    @Published var selectedShippingAddressId: String? {
        didSet {
            if useShippingAsBilling {
                selectedBillingAddressId = selectedShippingAddressId
            }
        }
    }

    // Billing Information
    @Published var useShippingAsBilling = true {
        didSet {
            if useShippingAsBilling {
                syncBillingWithShipping()
            }
        }
    }
    @Published var billingFirstName = ""
    @Published var billingLastName = ""
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
    @Published var showIntegrated3dsWebView = false
    @Published var showStandalone3dsWebView = false
    @Published var showMastercardWebView = false

    var alertTitle = ""
    var alertMessage = ""
    var viewState: ViewState?

    // Result Overlay State
    @Published var showResultOverlay = false
    @Published var resultIsSuccess = false
    @Published var resultMessage = ""

    private let useStandalone3DS = true

    // MARK: - Computed Properties

    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var formattedShippingAddress: String {
        var components: [String] = []

        if !shippingFirstName.isEmpty && !shippingLastName.isEmpty {
            components.append("\(shippingFirstName) \(shippingLastName)")
        }
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

        if !billingFirstName.isEmpty && !billingLastName.isEmpty {
            components.append("\(billingFirstName) \(billingLastName)")
        }
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
    private(set) var token3DS = ""

    // MARK: - Gateway IDs
    let applePayGatewayId = ProjectEnvironment.shared.getApplePayGatewayId() ?? ""
    let threeDSGatewayId = ProjectEnvironment.shared.getMPGSGatewayId() ?? ""
    let payPalGatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""

    // MARK: - Initialization

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        self.viewState = ViewState(state: .none)
    }
}
// MARK: - Apple Pay

extension EnhancedCheckoutVM {

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
        Task {
            isLoading = false
            switch result {
            case .success(let chargeResponse):
                showResultOverlay(success: true, message: "$\(chargeResponse.amount) succesfully charged!")
            case .failure(let error):
                showResultOverlay(success: false, message: error.customMessage)
            }
        }
    }
}

// MARK: - PayPal

extension EnhancedCheckoutVM {

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
            showResultOverlay(success: true, message: "$\(chargeResponse.amount) succesfully charged!")
        case .failure(let error):
            showResultOverlay(success: false, message: error.customMessage)
        }
    }
}

// MARK: - AfterPay

extension EnhancedCheckoutVM {

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let config = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: "1.0",
            maximumAmount: "100.0",
            currency: "AUD",
            language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions(shippingOptionRequired: true)
        return AfterpaySdkConfig(config: config, environment: .sandbox, options: options)
    }

    func getAfterpayShippingOptions() -> [ShippingOption] {
        let shippingOption1 = ShippingOption(
            id: cartManager.selectedShipping.name,
            name: cartManager.selectedShipping.name,
            description: cartManager.selectedShipping.description,
            shippingAmount: Money(amount: cartManager.stringShippingCost, currency: "AUD"),
            orderAmount: Money(amount: cartManager.stringTotalWithoutShipping, currency: "AUD"))

        return [shippingOption1]
    }

    func initializeAfterpayCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let initializeWalletChargeReq = createWalletChargeRequest(
                gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "",
                walletType: nil)

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
        isLoading = false
        switch result {
        case let .success(chargeResponse):
            showResultOverlay(success: true, message: "$\(chargeResponse.amount) succesfully charged!")
        case .failure:
            showResultOverlay(success: false, message: "Afterpay transaction failed.")
        }
    }
}

// MARK: - ColesPay

extension EnhancedCheckoutVM {

    func initializeWalletChargeColesPay(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        viewState?.setState(.disabled)
        let initializeWalletChargeReq = createWalletChargeRequest(
            gatewayId: ProjectEnvironment.shared.getColesPayGatewayId() ?? "",
            walletType: nil)

        Task {
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

    func handleColesPayResult(_ result: Result<String, ColesPayError>) {
        switch result {
        case .success:
            captureColesPayCharge()
        case let .failure(error):
            showResultOverlay(success: false, message: error.customMessage)
        }
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
                showResultOverlay(success: true, message: "Charge successful: \(res.amount) \(res.currency)")
            } catch {
                isLoading = false
                showResultOverlay(success: false, message: error.localizedDescription)
            }
        }
    }
}

// MARK: - ClickToPay

extension EnhancedCheckoutVM {

    func handleMastercardResult(_ result: Result<ClickToPayResult, ClickToPayError>) {
        switch result {
        case let .success(clickToPayResult):
            switch clickToPayResult.event {
            case .checkoutCompleted:
                showMastercardWebView = false
                payWithCard(clickToPayResult.mastercardToken)
            case .checkoutReady: break
            case .checkoutError:
                showMastercardWebView = false
                showResultOverlay(success: false, message: "Error with ClickToPay payment.")
            }

        case let .failure(error):
            showResultOverlay(success: false, message: error.customMessage)
        }
    }
}

// MARK: - Helper Methods

extension EnhancedCheckoutVM {

    private func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    /// Creates an Address object from the current shipping address data
    func getCurrentShippingAddress() -> Address? {
        guard shippingAddressComplete else { return nil }

        return Address(
            firstName: shippingFirstName,
            lastName: shippingLastName,
            addressLine1: address,
            addressLine2: addressLine2,
            city: city,
            state: state,
            postcode: postalCode,
            country: country
        )
    }

    /// Creates an Address object from the current billing address data
    func getCurrentBillingAddress() -> Address? {
        guard billingAddressComplete else { return nil }

        return Address(
            firstName: billingFirstName,
            lastName: billingLastName,
            addressLine1: billingAddress,
            addressLine2: billingAddressLine2,
            city: billingCity,
            state: billingState,
            postcode: billingPostalCode,
            country: billingCountry
        )
    }

    /// Shows the result overlay with success or error state
    func showResultOverlay(success: Bool, message: String) {
        resultIsSuccess = success
        resultMessage = message
        showResultOverlay = true
    }

    /// Syncs billing address fields with shipping address fields
    private func syncBillingWithShipping() {
        billingFirstName = shippingFirstName
        billingLastName = shippingLastName
        billingAddress = address
        billingAddressLine2 = addressLine2
        billingCity = city
        billingState = state
        billingPostalCode = postalCode
        billingCountry = country
        selectedBillingAddressId = selectedShippingAddressId
    }

    private func createWalletChargeRequest(gatewayId: String, walletType: String?) -> InitialiseWalletChargeReq {
        let paymentSource = InitialiseWalletChargePaymentSource(
            addressLine1: billingAddress,
            addressLine2: billingAddressLine2,
            addressPostcode: billingPostalCode,
            addressCity: billingCity,
            addressState: billingState,
            addressCountry: countryCode(from: billingCountry),
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
            merchantIdentifier: ProjectEnvironment.shared.getApplePayMerchantId() ?? "")
        return ApplePayRequestResult(request: paymentRequest, token: walletToken)
    }

    private func countryCode(from countryName: String) -> String? {
        for code in Locale.Region.isoRegions {
            let locale = Locale(identifier: "en")   // or use Locale.current
            if let name = locale.localizedString(forRegionCode: code.identifier),
               name.lowercased() == countryName.lowercased() {
                return code.identifier
            }
        }
        return nil
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

// MARK: - Card Payment

extension EnhancedCheckoutVM {

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
                if useStandalone3DS {
                    attemptStandalone3dsTokenCreation()
                } else {
                    attemptIntegrated3dsTokenCreation()
                }
            } catch {
                showResultOverlay(success: false, message: "Error converting to vault token!")
            }
        }
    }

    private func attemptIntegrated3dsTokenCreation() {
        let request = Integrated3DSVaultReq(
            amount: cartManager.stringTotal,
            currency: "AUD",
            customer: .init(
                paymentSource: .init(
                    vaultToken: vaultToken,
                    gatewayId: threeDSGatewayId)),
            threeDS: .init(browserDetails: .init()))
        Task {
            do {
                let response = try await walletService.createIntegrated3DSVaultToken(request: request)
                handleIntegrated3dsStatus(response)
            } catch {
                showResultOverlay(success: false, message: "Error creating integrated 3DS token!")
            }
        }
    }

    private func attemptStandalone3dsTokenCreation() {
        Task {
            let request = Standalone3DSReq(
                amount: cartManager.stringTotal,
                currency: "AUD",
                reference: UUID().uuidString,
                customer: .init(paymentSource: .init(token: vaultToken)),
                data: .init(
                    serviceId: ProjectEnvironment.shared.getGPaymentsServiceId() ?? "",
                    authentication: .init(
                        type: "01",
                        date: "2025-06-01T13:00:00.521Z",
                        version: "2.2.0",
                        customer: .init(
                            created: "2025-05-31T13:06:05.521Z",
                            updated: "2025-05-31T13:06:05.521Z",
                            credsUpdated: "2025-05-31T13:06:05.521Z",
                            suspicious: false,
                            source: .init(
                                created: "2025-05-31T13:06:05.521Z",
                                attempts: ["2025-05-31T13:06:05.521Z"],
                                cardType: "02"
                            )
                        )
                    )
                )
            )
            do {
                let response = try await walletService.createStandalone3DSToken(request: request)
                self.isLoading = false
                self.viewState?.setState(.none)
                self.token3DS = response ?? ""
                self.showStandalone3dsWebView = true
            } catch {
                showResultOverlay(success: false, message: "Error creating integrated 3DS token!")
            }
        }
    }

    /// Based on 3DS auth status selects the appropriate flow
    func handleIntegrated3dsStatus(_ response: Integrated3DSRes) {
        switch response.authStatus {
        case .notSupported: captureCharge(id3ds: response.resource.data.threeDS.id ?? "")
        case .pending:
            DispatchQueue.main.async {
                self.isLoading = false
                self.viewState?.setState(.none)
                self.token3DS = response.resource.data.threeDS.token ?? ""
                self.showIntegrated3dsWebView = true
            }
        case .none:
            showResultOverlay(success: false, message: "Error getting 3DS auth status!")
        }
    }

    /// Handles the outcome of integrated 3DS WebView check
    func handleIntegrated3dsEvent(_ event: Integrated3DSResult) {
        DispatchQueue.main.async {
            switch event.event {
            case .chargeAuth: break
            case .additionalDataCollectSuccess: break
            case .chargeAuthReject:
                self.showIntegrated3dsWebView = false
                self.showResultOverlay(success: false, message: "3DS auth rejected!")
            case .additionalDataCollectReject:
                self.showIntegrated3dsWebView = false
                self.showResultOverlay(success: false, message: "3DS additional data rejected!")
            case .chargeAuthCancelled:
                self.showIntegrated3dsWebView = false
                self.showResultOverlay(success: false, message: "3DS cancelled!")
            case .chargeAuthSuccess:
                self.showIntegrated3dsWebView = false
                self.captureCharge(id3ds: event.charge3dsId)
            }
        }
    }

    /// Handles the outcome of standlone  3DS WebView check
    func handleStandalone3dsEvent(_ event: Standalone3DSResult) {
        DispatchQueue.main.async {
            switch event.event {
            case .chargeAuthSuccess:
                self.showStandalone3dsWebView = false
                self.captureChargeForStandalone(id3ds: event.charge3dsId)
            case .chargeAuthReject:
                self.showStandalone3dsWebView = false
                self.showResultOverlay(success: false, message: "3DS auth rejected!")
            case .chargeAuthChallenge:
                break
            case .chargeAuthDecoupled:
                break
            case .chargeAuthInfo:
                break
            case .chargeError:
                self.showStandalone3dsWebView = false
                self.showResultOverlay(success: false, message: "3DS auth error!")
            }
        }
    }

    /// Captures the charge as the final step in the payment flow
    private func captureCharge(id3ds: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        viewState?.setState(.disabled)
        Task {
            let request = CaptureChargeReq(
                amount: cartManager.stringTotal,
                currency: "AUD",
                reference: UUID().uuidString,
                description: "Test Payment",
                threeDS: .init(id3DS: id3ds))

            do {
                let result = try await walletService.captureCharge(request: request)
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showResultOverlay(success: true, message: "\(result.amount) \(result.currency) successfully charged!")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showResultOverlay(success: false, message: "Payment failed. Please try again.")
                }
            }
        }
    }

    private func captureChargeForStandalone(id3ds: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        viewState?.setState(.disabled)
        Task {
            let request = CaptureChargeStandaloneReq(
                amount: cartManager.stringTotal,
                currency: "AUD",
                customer: .init(
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    paymentSource: .init(
                        gatewayID: applePayGatewayId,
                        vaultToken: vaultToken),
                    phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                    suspicious: false),
                description: "Test transaction standalone",
                reference: UUID().uuidString,
                threeDSChargeId: id3ds)

            do {
                let result = try await walletService.captureChargeForStandaloneFlow(request: request)
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showResultOverlay(success: true, message: "\(result.amount) \(result.currency) successfully charged!")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    viewState?.setState(.none)
                    showResultOverlay(success: false, message: "Payment failed. Please try again.")
                }
            }
        }
    }
}
