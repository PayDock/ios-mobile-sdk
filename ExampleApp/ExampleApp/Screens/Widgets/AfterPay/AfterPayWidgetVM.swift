//
//  AfterPayWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 19.02.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class AfterPayWidgetVM: ObservableObject {

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

    func initializeWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: "123 Test Street", addressPostcode: "BN3 5SL", gatewayId: ProjectEnvironment.shared.getAfterPayGatewayId() ?? "", walletType: nil)

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
                description: "Test transaction for AfterPay",
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

    func getAfterpayConfig() -> AfterpaySdkConfig {
        let theme = AfterpaySdkConfig.ButtonTheme(buttonType: .payNow, colorScheme: .static(.blackOnMint))
        let config = AfterpaySdkConfig.AfterPayConfiguration(minimumAmount: "1.0", maximumAmount: "100.0", currency: "AUD", language: "en_AU")
        let options = AfterpaySdkConfig.CheckoutOptions()
        return AfterpaySdkConfig(buttonTheme: theme, config: config, environment: .sandbox, options: options)
    }

    func handleError(error: Error) {
        alertTitle = "Error"
        alertMessage = "Transaction canceled"
        self.showAlert = true
    }

    func handleSuccess(_ chargeData: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "Charged \(chargeData.amount) \(chargeData.currency)"
        self.showAlert = true
    }
}
