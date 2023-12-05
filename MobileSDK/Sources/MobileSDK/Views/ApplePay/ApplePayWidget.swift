//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM

    public init(applePayRequest: ApplePayRequest,
                onCompletion: Binding<ChargeResponse?>,
                onFailure: Binding<ApplePayError?>) {
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

#Preview {
    ApplePayWidget(
        applePayRequest: .init(token: "asdf", merchanIdentifier: "asdf", request: PKPaymentRequest()),
        onCompletion: .constant(.init(status: "asd", amount: 10, currency: "USD"))
        , onFailure: .constant(.paymentFailed))
}
