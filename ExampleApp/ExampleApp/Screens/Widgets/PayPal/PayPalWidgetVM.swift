//
//  PayPalWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class PayPalWidgetVM: ObservableObject {

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
<<<<<<< HEAD
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: nil, addressPostcode: nil, gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "", walletType: nil)
=======
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: nil, addressPostcode: nil, gatewayId: "656dc6f13831577a1b43c526", walletType: nil)
>>>>>>> main

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "novaba9346@hondabbs.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeReq.MetaData(storeName: "Tom Taylor Ltd.", merchantName: "Tom's store", storeId: "1234556")

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
                    completion(token)
                }
            } catch {
                print("ERROR: Error fetching wallet token!")
            }
        }
    }

    func handleError(error: Error) {
        alertTitle = "Error"
        alertMessage = "\(error.localizedDescription)"
<<<<<<< HEAD
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
=======
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
>>>>>>> main
            self.showAlert = true
        }
    }

    func handleSuccess(charge: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "\(charge.amount) \(charge.currency) charged!"
<<<<<<< HEAD
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
=======
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
>>>>>>> main
            self.showAlert = true
        }
    }
}
