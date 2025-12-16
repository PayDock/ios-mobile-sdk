//
//  ColesPayExampleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 11.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import NetworkingLib
import OSLog

@MainActor
class ColesPayExampleVM: ObservableObject {

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

    func getConfig() -> ColesPayConfig {
        return configManager.getColesPayConfig()
    }

    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: "123 Test Street",
                addressLine2: nil,
                addressPostcode: "BN3 5SL",
                addressCity: "Test City",
                addressState: "Test State",
                addressCountry: "AU",
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
                amount: Decimal(string: configManager.getGlobalConfig().totalAmount) ?? 0,
                currency: configManager.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test transaction for Coles Pay",
                meta: metaData)

            do {
                let token = try await walletService.initialiseColesPayWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq).token
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

    func handleError(error: ColesPayError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
        }
    }

    func handleSuccess() {
        alertTitle = "Success"
        alertMessage = "Coles Pay success!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
        }
    }
}

// MARK: - WidgetLoadingDelegate

extension ColesPayExampleVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}

// MARK: - WidgetEventDelegate

extension ColesPayExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
