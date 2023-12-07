//
//  ApplePayWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 04.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class ApplePayWidgetVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var walletToken = ""
    @Published var applePayButtonEnabled = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func initializeWalletCharge() {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(gatewayId: "657045c00b76c9392bf5e36d")

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "tom.taylor@tommy.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeReq.MetaData(storeName: "Tom Taylor Ltd.", storeId: "1234556")

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: 10,
                currency: "USD",
                reference: "Test purchase",
                description: "Test purchase",
                meta: metaData)

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                DispatchQueue.main.async {
                    self.walletToken = token
                    self.applePayButtonEnabled = true
                }
            } catch {
                // TODO: Add example app error handling
                print("ERROR: Error fetching wallet token!")
            }
        }
    }

    func getApplePayRequest() -> ApplePayRequest {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: 5.50,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: "merchant.test-paydock")

        let applePayRequest = ApplePayRequest(
            token: walletToken,
            request: paymentRequest)

        return applePayRequest
    }


}
