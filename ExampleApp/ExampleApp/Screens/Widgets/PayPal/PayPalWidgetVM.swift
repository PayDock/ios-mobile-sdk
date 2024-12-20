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
    @Published var isLoading = false

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
    }

    func initializeWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: nil, addressPostcode: nil, gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "", walletType: nil)

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "novaba9346@hondabbs.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeReq.MetaData(
                storeName: "Tom Taylor Ltd.",
                merchantName: "Tom's store",
                storeId: "1234556",
                successUrl: nil,
                errorUrl: nil)

            let initializeWalletChargeReq = InitialiseWalletChargeReq(
                customer: customer,
                amount: 10,
                currency: "AUD",
                reference: UUID().uuidString,
                description: "Test transaction for PayPal",
                meta: metaData)

            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                DispatchQueue.main.async {
                    completion(token)
                }
            } catch {
                alertTitle = "Error"
                alertMessage = "Error fetching wallet token!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showAlert = true
                }
            }
        }
    }

    func handleError(error: Error) {
        alertTitle = "Error"
        alertMessage = "\(error.localizedDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }

    func handleSuccess(charge: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "\(charge.amount) \(charge.currency) charged!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }
}

extension PayPalWidgetVM: WidgetLoadingDelegate {
    func loadingDidStart() {
        isLoading = true
    }
    
    func loadingDidFinish() {
        isLoading = false
    }
}
