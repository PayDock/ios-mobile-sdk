//
//  ApplePayWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 04.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import NetworkingLib

@MainActor
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

    func initializeWalletCharge(completion: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) {
        Task {
            let paymentSource = InitialiseWalletChargePaymentSource(
                addressLine1: nil,
                addressPostcode: nil,
                gatewayId: ProjectEnvironment.shared.getApplePayGatewayId() ?? "",
                walletType: "apple")

            let customer = InitialiseWalletChargeCustomer(
                firstName: "Tom",
                lastName: "Taylor",
                email: "tom.taylor@tommy.com",
                phone: "+11234567890",
                paymentSource: paymentSource)

            let metaData = InitialiseWalletChargeMetaData(
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
                let applePayRequestResult = self.getApplePayRequestResult(walletToken: token)
                completion(.success(applePayRequestResult))

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: errorResponse.error?.message)))
            } catch let RequestError.connectionError(urlError) {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: urlError.localizedDescription)))
            } catch {
                isLoading = false
                completion(.failure(.initialisingWalletToken(reason: nil)))
            }
        }
    }

    func getApplePayRequestResult(walletToken: String) -> ApplePayRequestResult {
        let paymentRequest = MobileSDK.createApplePayRequest(
            amount: 10,
            amountLabel: "Amount",
            countryCode: "AU",
            currencyCode: "AUD",
            merchantIdentifier: ProjectEnvironment.shared.getMerchantId() ?? "")

        return ApplePayRequestResult(request: paymentRequest, token: walletToken)
    }

    func handleError(error: ApplePayError) {
        isLoading = false
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
