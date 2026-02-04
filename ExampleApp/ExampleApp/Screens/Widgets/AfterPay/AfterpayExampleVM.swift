//
//  AfterpayExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import Afterpay
import NetworkingLib
import OSLog
import CommonModels
import DataCharges

@MainActor
class AfterpayExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let chargesService: DataCharges.ChargesService
    private let configManager: ConfigManager

    // MARK: - Properties

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

    // MARK: Config

    func getConfig() -> AfterpaySdkConfig {
        return ConfigManager.shared.getAfterpayConfig()
    }

    func getAppearance(isDarkMode: Bool) -> AfterpayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .afterPay,
            isDarkMode: isDarkMode,
            as: AfterpayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? AfterpayWidgetAppearance()
    }

    // MARK: - Initialise Wallet

    func initializeWalletCharge(completion: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) {
        Task {
            let paymentSource = PaymentSource(
                gatewayId: ProjectEnvironment.shared.getAfterpayGatewayId() ?? "",
                addressLine1: "123 Test Street",
                addressLine2: "BN3 5SL",
                addressCity: "Test City",
                addressState: "Test State",
                addressPostcode: "Y35AK99",
                addressCountry: "AU")

            let customer = DataCharges.InitialiseWalletChargeCustomer(
                firstName: "David",
                lastName: "Cameron",
                email: "david.cameron@paydock.com",
                phone: "+1234567890",
                paymentSource: paymentSource)

            let metaData = DataCharges.InitialiseWalletChargeMetaData(
                storeName: "Tom Taylor Ltd.",
                merchantName: "Tom's store",
                storeId: "1234556",
                successUrl: "https://paydock-integration.netlify.app/success",
                errorUrl: "https://paydock-integration.netlify.app/error")

            let initializeWalletChargeReq = DataCharges.InitialiseWalletChargeReq(
                customer: customer,
                amount: Decimal(string: configManager.getGlobalConfig().totalAmount) ?? 0,
                currency: configManager.getGlobalConfig().currency,
                reference: UUID().uuidString,
                description: "Test transaction for Afterpay",
                meta: metaData)

            do {
                let token = try await chargesService.initialiseWalletCharge(
                    initializeWalletChargeReq: initializeWalletChargeReq, apiAccessToken: apiAccessToken
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

    // MARK: - Shipping

    func getShippingOptions() -> [ShippingOption] {
        let shippingOption1 = ShippingOption(
            id: "Standard",
            name: "Standard",
            description: "",
            shippingAmount: Money(amount: "5.0", currency: configManager.getGlobalConfig().currency),
            orderAmount: Money(amount: "10.0", currency: configManager.getGlobalConfig().currency))

        let shippingOption2 = ShippingOption(
            id: "Standard",
            name: "Standard",
            description: "",
            shippingAmount: Money(amount: "2.0", currency: configManager.getGlobalConfig().currency),
            orderAmount: Money(amount: "10.0", currency: configManager.getGlobalConfig().currency))

        return [shippingOption1, shippingOption2]
    }

    func getShippingOptionUpdate() -> ShippingOptionUpdate {
        return ShippingOptionUpdate(
            id: "Standard",
            shippingAmount: Money(amount: "5.0", currency: configManager.getGlobalConfig().currency),
            orderAmount: Money(amount: "10.0", currency: configManager.getGlobalConfig().currency))
    }

    // MARK: - Handle Callbacks

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

extension AfterpayExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
