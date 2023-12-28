//
//  CheckoutPaymentSheet.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 15.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct CheckoutPaymentSheet: View {

    @StateObject private var viewModel: CheckoutPaymentVM

    init(viewModel: CheckoutPaymentVM = CheckoutPaymentVM()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            title()
            selector()
            switch viewModel.selectedMethod {
            case .card:
                CardDetailsWidget(gatewayId: "", completion: { result in

                })
            case .applePay:
                ApplePayWidget { onApplePayButtonTap in
//                    viewModel.initializeWalletCharge(completion: onApplePayButtonTap)
                } completion: { result in
//                    switch result {
//                    case .success(let chargeResponse): break
//                    case .failure(let error): break
                }
            case .payPal:
                PayPalWidget { onPayPalButtonTap in
//                    viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
                } completion: { result in
//                    switch result {
//                    case .success(let chargeResponse): break
//                    case .failure(let error): break
//                    }
                }
            }
        }
    }

    func title() -> some View {
        HStack {
            Text("Payment Method")
                .font(.title3)
                .padding(.leading, 16)
            Spacer()
        }
    }

    func selector() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                paymentMethodCell(type: .card, logo: Image("credit-card"), title: "Card")
                paymentMethodCell(type: .applePay, logo: Image("applePay"))
                paymentMethodCell(type: .payPal, logo: Image("payPal"))

            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }

    func paymentMethodCell(type: CheckoutPaymentVM.PaymentMethod, logo: Image, title: String? = nil) -> some View {
        HStack {
            logo
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.4, green: 0.31, blue: 0.64))
            }
        }
        .frame(width: 90, height: 49)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke( type == viewModel.selectedMethod ? Color(red: 0.4, green: 0.31, blue: 0.64) : .black, lineWidth: type == viewModel.selectedMethod ? 2 : 1/3)
        )
        .onTapGesture {
            viewModel.selectedMethod = type
        }
    }


}

struct PaymentMethodSelector_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentSheet()
    }
}
