//
//  ApplePayVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import Foundation
import PassKit

class ApplePayVM: NSObject, ObservableObject {

    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    let applePayRequest: ApplePayRequest

    init(applePayRequest: ApplePayRequest) {
        self.applePayRequest = applePayRequest
    }

    func startPayment() {
        let paymentRequest = applePayRequest.request

        // Display our payment request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
            }
        })
        // TODO: - Finalise this once other endpoints are implemented
    }

}

extension ApplePayVM: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {

    }

}


