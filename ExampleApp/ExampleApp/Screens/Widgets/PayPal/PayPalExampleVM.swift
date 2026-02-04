//
//  PayPalExampleVM.swift
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
class PayPalExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let chargesService: DataCharges.ChargesService
    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    // MARK: - Initialisation

    init(chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl(),
         configManager: ConfigManager = .shared) {
        self.chargesService = chargesService
        self.configManager = configManager
    }

    private var apiAccessToken: String {
        return configManager.getGlobalConfig().apiAccessToken
    }

    // MARK: - Config

    func getConfig() -> PayPalWidgetConfig {
        return configManager.getPayPalConfig()
    }

    func getAppearance(isDarkMode: Bool) -> PayPalWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .paypal,
            isDarkMode: isDarkMode,
            as: PayPalWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? PayPalWidgetAppearance()
    }

    // MARK: - Logic

    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = PaymentSource(
                gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
            )

            let customer = DataCharges.InitialiseWalletChargeCustomer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "novaba9346@hondabbs.com",
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
                description: "Test transaction for PayPal",
                meta: metaData)

            do {
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq,
                    apiAccessToken: apiAccessToken
                )
                completion(.success(.init(token: token)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
            } catch {
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func handleError(error: PayPalError) {
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

// MARK: - WidgetLoadingDelegate

extension PayPalExampleVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}

// MARK: - WidgetEventDelegate

extension PayPalExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
