//
//  PayPalWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

import Foundation
import MobileSDK

class PayPalWidgetVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var walletToken = ""
    @Published var payPalButtonEnabled = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func initializeWalletCharge() {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(gatewayId: "6481c786d9cc9c39993e5933")

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "novaba9346@hondabbs.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeReq.MetaData(storeName: "Tom Taylor Ltd.", storeId: "1234556")

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: 10,
                currency: "USD",
                reference: UUID().uuidString,
                description: "Test transaction for PayPal",
                meta: metaData)

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                DispatchQueue.main.async {
                    self.walletToken = token
                    self.payPalButtonEnabled = true
                }
            } catch {
                // TODO: Add example app error handling
                print("ERROR: Error fetching wallet token!")
            }
        }
    }

}
