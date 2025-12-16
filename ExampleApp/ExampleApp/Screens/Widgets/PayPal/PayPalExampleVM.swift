//
//  PayPalExampleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import NetworkingLib
import OSLog

@MainActor
class PayPalExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService
    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl(),
         configManager: ConfigManager = .shared) {
        self.walletService = walletService
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> PayPalWidgetConfig {
        return configManager.getPayPalConfig()
    }

    // MARK: - Logic

    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: nil,
                addressLine2: nil,
                addressPostcode: nil,
                addressCity: nil,
                addressState: nil,
                addressCountry: nil,
                gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
                walletType: nil)

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
                amount: Decimal(string: configManager.getGlobalConfig().totalAmount) ?? 0,
                currency: configManager.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test transaction for PayPal",
                meta: metaData)

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                DispatchQueue.main.async {
                    completion(.success(.init(token: token)))
                }
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
