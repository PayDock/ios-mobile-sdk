//
//  EnhancedCheckoutVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import MobileSDK
import Afterpay
import NetworkingLib
import PassKit
import CommonModels
import DataCharges
import DataVault
import DataMPGS3ds
import DataStandalone3ds

@MainActor
// swiftlint:disable file_length
class EnhancedCheckoutVM: ObservableObject {

    // MARK: - Dependencies
    private let vaultService: DataVault.VaultService
    private let chargesService: DataCharges.ChargesService
    private let mpgs3dsService: DataMPGS3ds.MPGS3dsService
    private let standalone3dsService: DataStandalone3ds.Standalone3dsService
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
    @Published var zipToken = ""

    // UI State
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var orderCompleted = false
    @Published var showMPGS3dsWebView = false
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
    let mpgsGatewayId = ProjectEnvironment.shared.getMPGSGatewayId() ?? ""
    let applePayGatewayId = ProjectEnvironment.shared.getApplePayGatewayId() ?? ""
    let threeDSGatewayId = ProjectEnvironment.shared.getMPGSGatewayId() ?? ""
    let payPalGatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""

    // MARK: - Initialization

    init(vaultService: DataVault.VaultService = DataVault.VaultServiceImpl(),
         chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl(),
         mpgs3dsService: DataMPGS3ds.MPGS3dsService = DataMPGS3ds.MPGS3dsServiceImpl(),
         standalone3dsService: DataStandalone3ds.Standalone3dsService = DataStandalone3ds.Standalone3dsServiceImpl()) {
        self.vaultService = vaultService
        self.chargesService = chargesService
        self.mpgs3dsService = mpgs3dsService
        self.standalone3dsService = standalone3dsService
        self.viewState = ViewState(state: .none)
    }

    private var apiAccessToken: String {
        return ConfigManager.shared.getGlobalConfig().apiAccessToken
    }
}

// MARK: - Apple Pay

extension EnhancedCheckoutVM {

    func initializeApplePayCharge(completion: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) {
        Task {
            do {
                isLoading = true
                let request = createWalletChargeRequest(gatewayId: applePayGatewayId, walletType: "apple")
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: request,
                    apiAccessToken: apiAccessToken
                )
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
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: request,
                    apiAccessToken: apiAccessToken
                )
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
        let options = AfterpaySdkConfig.CheckoutOptions(shippingOptionRequired: true)
        return AfterpaySdkConfig(
            environment: {
                switch ProjectEnvironment.shared.environment {
                case .production: return .production
                case .sandbox, .staging: return .sandbox
                }
            }(),
            options: options
        )
    }

    func getAfterpayShippingOptions() -> [ShippingOption] {
        let currency = ConfigManager.shared.getGlobalConfig().currency
        let shippingOption1 = ShippingOption(
            id: cartManager.selectedShipping.name,
            name: cartManager.selectedShipping.name,
            description: cartManager.selectedShipping.description,
            shippingAmount: Money(amount: cartManager.stringShippingCost, currency: currency),
            orderAmount: Money(amount: cartManager.stringTotalWithoutShipping, currency: currency))

        return [shippingOption1]
    }

    func initializeAfterpayCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let initializeWalletChargeReq = createWalletChargeRequest(
                gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "",
                walletType: nil)

            do {
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq,
                    apiAccessToken: apiAccessToken
                )
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
                let response = try await chargesService.initialiseColesPayWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq,
                    apiAccessToken: apiAccessToken
                )
                let token = response.token
                self.colesPayChargeId = response.charge.id
                completion(.success(WalletTokenResult(token: token)))
                self.viewState?.setState(.none)
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
}

// MARK: - ClickToPay

extension EnhancedCheckoutVM {

    func handleClickToPayResult(_ result: Result<ClickToPayResult, ClickToPayError>) {
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

// MARK: - Zip

extension EnhancedCheckoutVM {

    // swiftlint:disable:next function_body_length
    func getZipConfig() -> ZipWidgetConfig {
        let globalConfig = ConfigManager.shared.getGlobalConfig()
        let currency = globalConfig.currency
        let amount = Decimal(cartManager.total)

        // Get saved addresses to access firstName/lastName from selected addresses
        let savedAddresses = UserProfileManager.shared.profile.savedAddresses

        // Get shipping address name from saved address if selected, otherwise use contact info
        let selectedShippingAddress = selectedShippingAddressId.flatMap { id in
            savedAddresses.first { $0.id == id }
        }
        let shippingFirstNameValue = selectedShippingAddress?.firstName.isEmpty == false
            ? selectedShippingAddress!.firstName
            : (self.shippingFirstName.isEmpty ? self.firstName : self.shippingFirstName)
        let shippingLastNameValue = selectedShippingAddress?.lastName.isEmpty == false
            ? selectedShippingAddress!.lastName
            : (self.shippingLastName.isEmpty ? self.lastName : self.shippingLastName)

        // Get billing address name
        let selectedBillingAddress = useShippingAsBilling
            ? selectedShippingAddress
            : selectedBillingAddressId.flatMap { id in
                savedAddresses.first { $0.id == id }
            }
        let billingFirstNameValue = selectedBillingAddress?.firstName.isEmpty == false
            ? selectedBillingAddress!.firstName
            : (self.billingFirstName.isEmpty ? self.firstName : self.billingFirstName)
        let billingLastNameValue = selectedBillingAddress?.lastName.isEmpty == false
            ? selectedBillingAddress!.lastName
            : (self.billingLastName.isEmpty ? self.lastName : self.billingLastName)

        // Convert cart items to Zip items
        let items = cartManager.cartItems.map { cartItem in
            ZipWidgetConfig.Item(
                name: cartItem.product.name,
                amount: String(format: "%.2f", cartItem.product.price),
                quantity: cartItem.quantity,
                reference: cartItem.product.id
            )
        }

        // Convert billing address
        let billingAddress: ZipWidgetConfig.Address? = billingAddressComplete
            ? ZipWidgetConfig.Address(
                firstName: billingFirstNameValue,
                lastName: billingLastNameValue,
                line1: billingAddress,
                line2: billingAddressLine2.isEmpty ? nil : billingAddressLine2,
                city: billingCity,
                state: billingState,
                postcode: billingPostalCode,
                country: countryCode(from: billingCountry)
            )
            : nil

        // Convert shipping address
        let shippingAddress: ZipWidgetConfig.Address? = shippingAddressComplete
            ? ZipWidgetConfig.Address(
                firstName: shippingFirstNameValue,
                lastName: shippingLastNameValue,
                line1: address,
                line2: addressLine2.isEmpty ? nil : addressLine2,
                city: city,
                state: state,
                postcode: postalCode,
                country: countryCode(from: country)
            )
            : nil

        // Get Zip config from ConfigManager to use configured values
        let zipConfig = ConfigManager.shared.getZipConfig()

        return ZipWidgetConfig(
            accessToken: zipConfig.accessToken,
            gatewayId: zipConfig.gatewayId,
            amount: amount,
            currency: currency,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            tokenize: true,
            gender: "Male",
            dateOfBirth: "1990-10-16",
            shippingType: "delivery",
            billing: billingAddress,
            shipping: shippingAddress,
            items: items,
            statistics: nil
        )
    }

    func handleZipResult(_ result: Result<String, ZipError>) {
        isLoading = false
        switch result {
        case let .success(token):
            self.captureChargeWallet(walletToken: token)
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
        // Note: This method may be called from non-isolated contexts (e.g., widget completion handlers)
        // so we use Task { @MainActor in } to ensure main thread execution
        Task { @MainActor in
            self.isLoading = false
            self.viewState?.setState(.none)
            self.resultIsSuccess = success
            self.resultMessage = message
            self.showResultOverlay = true
        }
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

    private func createWalletChargeRequest(gatewayId: String, walletType: String?) -> DataCharges.InitialiseWalletChargeReq {
        let paymentSource = PaymentSource(
            walletType: walletType,
            gatewayId: gatewayId,
            addressLine1: billingAddress,
            addressLine2: billingAddressLine2.isEmpty ? nil : billingAddressLine2,
            addressCity: billingCity,
            addressState: billingState,
            addressPostcode: billingPostalCode,
            addressCountry: countryCode(from: billingCountry)
        )

        let customer = DataCharges.InitialiseWalletChargeCustomer(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            paymentSource: paymentSource
        )

        let metaData = DataCharges.InitialiseWalletChargeMetaData(
            storeName: "Demo Store",
            merchantName: "Demo Merchant",
            storeId: "demo123",
            successUrl: "https://demo.com/success",
            errorUrl: "https://demo.com/error"
        )

        return DataCharges.InitialiseWalletChargeReq(
            customer: customer,
            amount: Decimal(cartManager.total),
            currency: ConfigManager.shared.getGlobalConfig().currency,
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
            currencyCode: ConfigManager.shared.getGlobalConfig().currency,
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

        let request = DataVault.ConvertToVaultTokenReq(token: cardToken, vaultType: "session")
        Task {
            do {
                let vaultToken = try await vaultService.convertCardTokenToVaultToken(request: request, apiAccessToken: apiAccessToken)
                self.vaultToken = vaultToken
                if useStandalone3DS {
                    attemptStandalone3dsTokenCreation()
                } else {
                    attemptMPGS3dsTokenCreation()
                }
            } catch {
                showResultOverlay(success: false, message: "Error converting to vault token!")
            }
        }
    }
}

// MARK: - Handle 3ds

extension EnhancedCheckoutVM {

    private func attemptMPGS3dsTokenCreation() {
        let request = DataMPGS3ds.MPGS3dsVaultReq(
            amount: cartManager.stringTotal,
            currency: ConfigManager.shared.getGlobalConfig().currency,
            customer: .init(
                paymentSource: .init(
                    vaultToken: vaultToken,
                    gatewayId: threeDSGatewayId
                )
            ),
            threeDS: .init(browserDetails: .init()))
        Task {
            do {
                let response = try await mpgs3dsService.createMPGS3dsVaultToken(request: request, apiAccessToken: apiAccessToken)
                handleMPGS3dsStatus(response)
            } catch {
                showResultOverlay(success: false, message: "Error creating MPGS 3DS token!")
            }
        }
    }

    private func attemptStandalone3dsTokenCreation() {
        Task {
            let request = DataStandalone3ds.Standalone3DSReq(
                amount: cartManager.stringTotal,
                currency: ConfigManager.shared.getGlobalConfig().currency,
                reference: UUID().uuidString,
                customer: .init(paymentSource: .init(vaultToken: vaultToken)),
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
                let response = try await standalone3dsService.createStandalone3DSToken(request: request, apiAccessToken: apiAccessToken)
                self.isLoading = false
                self.viewState?.setState(.none)
                self.token3DS = response ?? ""
                self.showStandalone3dsWebView = true
            } catch {
                showResultOverlay(success: false, message: "Error creating standalone 3DS token!")
            }
        }
    }

    /// Based on 3DS auth status selects the appropriate flow
    func handleMPGS3dsStatus(_ response: DataMPGS3ds.MPGS3dsRes) {
        switch response.authStatus {
        case .notSupported: captureChargeMPGS(id3ds: response.resource.data.threeDS.id)
        case .pending:
            Task {
                self.isLoading = false
                self.viewState?.setState(.none)
                self.token3DS = response.resource.data.threeDS.token ?? ""
                self.showMPGS3dsWebView = true
            }
        case .none:
            showResultOverlay(success: false, message: "Error getting MPGS 3DS auth status!")
        }
    }

    /// Handles the outcome of MPGS 3DS WebView check
    /// Note: This method is @MainActor, so it will execute on main thread even if called from non-isolated context
    func handleMPGS3dsEvent(_ event: MPGS3dsResult) {
        Task {
            switch event.event {
            case .chargeAuth: break
            case .additionalDataCollectSuccess: break
            case .chargeAuthReject:
                self.showMPGS3dsWebView = false
                self.showResultOverlay(success: false, message: "MPGS 3DS auth rejected!")
            case .additionalDataCollectReject:
                self.showMPGS3dsWebView = false
                self.showResultOverlay(success: false, message: "MPGS 3DS additional data rejected!")
            case .chargeAuthCancelled:
                self.showMPGS3dsWebView = false
                self.showResultOverlay(success: false, message: "MPGS 3DS cancelled!")
            case .chargeAuthSuccess:
                self.showMPGS3dsWebView = false
                self.captureChargeMPGS(id3ds: event.charge3dsId)
            }
        }
    }

    /// Handles the outcome of standlone  3DS WebView check
    /// Note: This method is @MainActor, so it will execute on main thread even if called from non-isolated context
    func handleStandalone3dsEvent(_ event: Standalone3DSResult) {
        Task {
            switch event.event {
            case .chargeAuthSuccess:
                self.showStandalone3dsWebView = false
                self.captureChargeForStandalone(id3ds: event.charge3dsId)
            case .chargeAuthReject:
                self.showStandalone3dsWebView = false
                self.showResultOverlay(success: false, message: "Standalone 3DS auth rejected!")
            case .chargeAuthChallenge:
                break
            case .chargeAuthDecoupled:
                break
            case .chargeAuthInfo:
                break
            case .chargeError:
                self.showStandalone3dsWebView = false
                self.showResultOverlay(success: false, message: "Standalone 3DS auth error!")
            }
        }
    }
}

// MARK: - Charges

extension EnhancedCheckoutVM {

    /// Captures the charge as the final step in the payment flow
    private func captureChargeMPGS(id3ds: String) {
        isLoading = true
        viewState?.setState(.disabled)
        Task {
            let request = DataCharges.CaptureChargeReq(
                amount: cartManager.stringTotal,
                currency: ConfigManager.shared.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test Payment",
                threeDS: .init(id: id3ds))

            do {
                let result = try await chargesService.captureCharge(request: request, apiAccessToken: apiAccessToken)
                showResultOverlay(success: true, message: "\(result.data.amount) \(result.data.currency) successfully charged!")
            } catch {
                showResultOverlay(success: false, message: "Payment failed. Please try again.")
            }
        }
    }

    private func captureChargeForStandalone(id3ds: String) {
        isLoading = true
        viewState?.setState(.disabled)
        Task {
            let request = DataCharges.CaptureChargeStandaloneReq(
                amount: cartManager.stringTotal,
                currency: ConfigManager.shared.getGlobalConfig().currency,
                customer: .init(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                    paymentSource: .init(
                        vaultToken: vaultToken, gatewayId: mpgsGatewayId
                    ),
                    externalId: "1234",
                    suspicious: false),
                description: "Test transaction standalone",
                reference: UUID().uuidString,
                threeDSChargeId: id3ds)

            do {
                let result = try await chargesService.captureChargeForStandaloneFlow(request: request, apiAccessToken: apiAccessToken)
                showResultOverlay(success: true, message: "\(result.data.amount) \(result.data.currency) successfully charged!")
            } catch {
                showResultOverlay(success: false, message: "Payment failed. Please try again.")
            }
        }
    }

    /// Captures the charge as the final step in the payment flow
    private func captureChargeWallet(walletToken: String) {
        isLoading = true
        viewState?.setState(.disabled)
        Task {
            let request = DataCharges.CaptureChargeReq(
                amount: cartManager.stringTotal,
                currency: ConfigManager.shared.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test Payment",
                token: walletToken)

            do {
                let result = try await chargesService.captureCharge(request: request, apiAccessToken: apiAccessToken)
                showResultOverlay(success: true, message: "\(result.data.amount) \(result.data.currency) successfully charged!")
            } catch {
                showResultOverlay(success: false, message: "Payment failed. Please try again.")
            }
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
                let res = try await chargesService.captureChargeColesPay(chargeId: colesPayChargeId, apiAccessToken: apiAccessToken)
                showResultOverlay(success: true, message: "Coles Pay Charge successful: \(res.data.amount) \(res.data.currency)")
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                let errorMessage = errorResponse.error?.message ?? errorResponse.errorSummary?.message ?? "Unknown error"
                showResultOverlay(success: false, message: errorMessage)
            } catch {
                isLoading = false
                showResultOverlay(success: false, message: "Unknown error")
            }
        }
    }
}
