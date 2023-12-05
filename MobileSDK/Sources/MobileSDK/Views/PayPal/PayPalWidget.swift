//
//  PayPalWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI

public struct PayPalWidget: View {
    @StateObject private var viewModel: PayPalVM

    public init(payPalToken: String,
                completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalVM(payPalToken: payPalToken, completion: completion))
    }

    public var body: some View {
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

#Preview {
    PayPalWidget(payPalToken: "", completion: { _ in })
}
