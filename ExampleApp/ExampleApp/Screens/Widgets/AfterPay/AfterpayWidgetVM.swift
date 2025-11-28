//
//  AfterpayWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.02.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import Afterpay
import NetworkingLib
import OSLog

@MainActor
class AfterpayWidgetVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
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

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let config = AfterpaySdkConfig.AfterpayConfiguration(
            minimumAmount: "1.0",
            maximumAmount: "100.0",
            currency: "AUD",
            language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions()
        let environment: Environment = {
            switch ProjectEnvironment.shared.environment {
            case .production: return .production
            case .sandbox, .staging: return .sandbox
            }
        }()
        return AfterpaySdkConfig(config: config, environment: environment, options: options)
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

    func handleError(error: AfterpayError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        self.showAlert = true
    }

    func handleSuccess(_ chargeData: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "Charged \(chargeData.amount) \(chargeData.currency)"
        self.showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension AfterpayWidgetVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
