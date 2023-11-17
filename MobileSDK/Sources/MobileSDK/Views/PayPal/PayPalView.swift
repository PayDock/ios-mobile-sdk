//
//  PayPalView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI

struct PayPalView: View {
    @StateObject private var viewModel: PayPalVM

    public init(payPalToken: String,
                onCompletion: Binding<ChargeResponse?>,
                onFailure: Binding<PayPalError?>) {
        _viewModel = StateObject(wrappedValue: PayPalVM(
            payPalToken: payPalToken,
            onCompletion: onCompletion,
            onFailure: onFailure))
    }

    var body: some View {
        VStack {
            LargeButton(title: "", image: Image("pay-pal", bundle: Bundle.module), backgroundColor: Color(red: 1.0, green: 0.76, blue: 0.30)) {
                viewModel.getPayPalURL()
            }
        }
        .sheet(isPresented: $viewModel.showWebView) {
            NavigationStack {
                VStack {
                    if let url = viewModel.payPalUrl {
                        PayPalWebView(url: url, onApprove: { paymentMethodId, payerId in
                            viewModel.capturePayPalPayment(paymentMethodId: paymentMethodId, payerId: payerId)
                        }, onFailure: { error in
                            // TODO: Handle error
                        })
                        .navigationTitle("Checkout with PayPal")
                        .navigationBarTitleDisplayMode(.inline)
                    }

                }
            }
        }
        .padding()
    }

}

//#Preview {
//    PayPalView(
//        applePayRequest: .init(token: "asdf", merchanIdentifier: "asdf", request: .),
//        onCompletion: .constant(.init(status: "asd", amount: 10, currency: "USD"))
//        , onFailure: .constant(.paymentFailed))
//}
