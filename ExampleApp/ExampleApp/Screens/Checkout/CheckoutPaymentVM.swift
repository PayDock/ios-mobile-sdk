//
//  CheckoutPaymentVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class CheckoutPaymentVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var selectedMethod: PaymentMethod = .card

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
    }

    // MARK: - Wallet

    func initializeWalletCharge(completion: @escaping (String) -> Void) {
        Task {
            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: createWalletChargeRequest())
                DispatchQueue.main.async {
                    completion(token)
                }
            } catch {
                print("ERROR: Error fetching wallet token!")
            }
        }
    }

    func initializeWalletCharge(completion: @escaping (ApplePayRequest) -> Void) {
        Task {
            do {
                let token = try await walletService.initialiseWalletCharge(initializeWalletChargeReq: createWalletChargeRequest())
                DispatchQueue.main.async {
                    let applePayRequest = self.getApplePayRequest(walletToken: token)
                    completion(applePayRequest)
                }
            } catch {
                print("ERROR: Error fetching wallet token!")
            }
        }
    }

    func getApplePayRequest(walletToken: String) -> ApplePayRequest {
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

    func createWalletChargeRequest() -> InitialiseWalletChargeReq {
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

        return initializeWalletChargeReq
    }

    enum PaymentMethod {
        case card
        case applePay
        case payPal
    }

}
