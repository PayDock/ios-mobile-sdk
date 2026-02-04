//
//  ApplePayExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import MobileSDK
import NetworkingLib
import OSLog
import CommonModels
import DataCharges

@MainActor
class ApplePayExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let chargesService: DataCharges.ChargesService
    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private var apiAccessToken: String {
        return configManager.getGlobalConfig().apiAccessToken
    }

    // MARK: - Initialisation

    init(chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl(),
         configManager: ConfigManager = .shared) {
        self.chargesService = chargesService
        self.configManager = configManager
    }

    // MARK: - Config

    func getAppearance(isDarkMode: Bool) -> ApplePayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .applePay,
            isDarkMode: isDarkMode,
            as: ApplePayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ApplePayWidgetAppearance()
    }

    // MARK: - Initialise Wallet

    func initializeWalletCharge(completion: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) {
        Task {
            let paymentSource = PaymentSource(
                walletType: "apple",
                gatewayId: ProjectEnvironment.shared.getApplePayGatewayId() ?? "",
                addressLine1: "123 Test Street",
                addressLine2: "BN3 5SL",
                addressCity: "Test City",
                addressState: "Test State",
                addressPostcode: "Y35AK99",
                addressCountry: "AU"
            )

            let customer = DataCharges.InitialiseWalletChargeCustomer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "tom.taylor@tommy.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = DataCharges.InitialiseWalletChargeMetaData(
                storeName: "Tom Taylor Ltd.",
                merchantName: "Tom's store",
                storeId: "1234556",
                successUrl: nil,
                errorUrl: nil)

            let initializeWalletChargeReq = DataCharges.InitialiseWalletChargeReq(
                customer: customer,
                amount: Decimal(string: configManager.getGlobalConfig().totalAmount) ?? 0,
                currency: configManager.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test purchase",
                meta: metaData)

            do {
                isLoading = true
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq, apiAccessToken: apiAccessToken
                )
                let applePayRequestResult = self.getApplePayRequestResult(walletToken: token)
                completion(.success(applePayRequestResult))
                isLoading = false

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
            } catch {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func getApplePayRequestResult(walletToken: String) -> ApplePayRequestResult {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: Decimal(string: configManager.getGlobalConfig().totalAmount) ?? 0,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: configManager.getGlobalConfig().currency,
            merchantIdentifier: ProjectEnvironment.shared.getApplePayMerchantId() ?? "")

        return ApplePayRequestResult(request: paymentRequest, token: walletToken)
    }

    // MARK: - Handle Callbacks

    func handleError(error: ApplePayError) {
        isLoading = false
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        showAlert = true
    }

    func handleSuccess(charge: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "\(charge.amount) \(charge.currency) charged!"
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension ApplePayExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
