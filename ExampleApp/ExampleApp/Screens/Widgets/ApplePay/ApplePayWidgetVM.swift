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

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
        super.init()
    }

    func initializeWalletCharge(completion: @escaping (ApplePayRequest) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargeReq.Customer.PaymentSource(addressLine1: nil, addressPostcode: nil, gatewayId: ProjectEnvironment.shared.getApplePayGatewayId() ?? "", walletType: "apple")

            let customer = InitialiseWalletChargeReq.Customer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "tom.taylor@tommy.com",
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
                description: "Test purchase",
                meta: metaData)

            do {
                isLoading = true
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: initializeWalletChargeReq)
                DispatchQueue.main.async {
                    let applePayRequest = self.getApplePayRequest(walletToken: token)
                    completion(applePayRequest)
                }
            } catch {
                isLoading = false
                alertTitle = "Error"
                alertMessage = "Error fetching wallet token!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showAlert = true
                }
            }
        }
    }

    func getApplePayRequest(walletToken: String) -> ApplePayRequest {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: 10,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: "merchant.test-paydock")

        let applePayRequest = ApplePayRequest(
            token: walletToken,
            request: paymentRequest)

        return applePayRequest
    }

    func handleError(error: ApplePayError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
        }
    }

    func handleSuccess(charge: ChargeResponse) {
        alertTitle = "Success"
        alertMessage = "\(charge.amount) \(charge.currency) charged!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert = true
        }
    }
}
