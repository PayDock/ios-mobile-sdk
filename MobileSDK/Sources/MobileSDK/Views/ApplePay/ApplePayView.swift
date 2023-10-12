//
//  ApplePayView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI

struct ApplePayView: View {
    @StateObject private var viewModel: ApplePayVM
    @Binding private var onCompletion: ChargeResponse?
    @Binding private var onFailure: ApplePayError?

    public init(applePayRequest: ApplePayRequest,
                onCompletion: Binding<ChargeResponse?>,
                onFailure: Binding<ApplePayError?>) {
        self._onCompletion = onCompletion
        self._onFailure = onFailure
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            applePayRequest: applePayRequest,
            onCompletion: onCompletion,
            onFailure: onFailure))
    }

    var body: some View {
        ApplePayButton {
            viewModel.startPayment()
        }
        .padding()
    }
    
}

//#Preview {
//    ApplePayView(
//        applePayRequest: .init(token: "asdf", merchanIdentifier: "asdf", request: .),
//        onCompletion: .constant(.init(status: "asd", amount: 10, currency: "USD"))
//        , onFailure: .constant(.paymentFailed))
//}
