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
                VStack {
                    CardDetailsWidget(gatewayId: "", completion: { result in
                        switch result {
                        case .success(let token): viewModel.saveCardToken(token)
                        case .failure: break
                        }
                    })
                    .frame(height: 320)
                    Button("Pay") {
                        viewModel.payWithCard()
                    }
                    .foregroundStyle(.white)
                    .font(Font.system(size: 16, weight: .semibold))
                    .frame(height: 48)
                    .frame(maxWidth:.infinity)
                    .background(Color(hex: "6750A4"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding()
                }

            case .applePay:
                ApplePayWidget { onApplePayButtonTap in
                    viewModel.initializeWalletCharge(completion: onApplePayButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse):
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = chargeResponse.status
                        viewModel.showAlert = true
                    
                    case .failure(let error):
                        viewModel.alertTitle = "Failure"
                        viewModel.alertMessage = error.customMessage
                        viewModel.showAlert = true
                    }
                }
                .padding()
            case .payPal:
                PayPalWidget { onPayPalButtonTap in
                    viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse):
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = chargeResponse.status
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            viewModel.showAlert = true
                        }

                    case .failure(let error):
                        viewModel.alertTitle = "Failure"
                        viewModel.alertMessage = error.customMessage
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            viewModel.showAlert = true
                        }
                    }
                }
                .padding()

            case .mastercard:
                Button("Checkout with Mastercard") {
                    viewModel.showMastercardWebView = true
                }
                .foregroundStyle(.white)
                .font(Font.system(size: 16, weight: .semibold))
                .frame(height: 48)
                .frame(maxWidth:.infinity)
                .background(Color(hex: "6750A4"))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding()
                .sheet(isPresented: $viewModel.showMastercardWebView, content: {
                    NavigationStack {
                        VStack {
                            MastercardWidget(serviceId: ProjectEnvironment.shared.getMastercardServiceId() ?? "") { result in
                                viewModel.handleMastercardResult(result)
                            }
                            .navigationTitle("Checkout with Mastercard")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }

                })
            }
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
            Text(viewModel.alertMessage)
        })
        .sheet(isPresented: $viewModel.show3dsWebView, onDismiss: { }) {
            NavigationStack {
                VStack {
                    ThreeDSWidget(
                        token: viewModel.token3DS,
                        baseURL: viewModel.getBaseUrl(),
                        completion: { event in
                            viewModel.handle3dsEvent(event)
                        })
                    .navigationTitle("3DS Check")
                    .navigationBarTitleDisplayMode(.inline)

                }
            }
        }
    }

    private func title() -> some View {
        HStack {
            Text("Payment Method")
                .font(.title3)
                .padding(.leading, 16)
            Spacer()
        }
    }

    private func selector() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                paymentMethodCell(type: .card, logo: Image("credit-card-fill"), title: "Card")
                paymentMethodCell(type: .applePay, logo: Image("applePay"))
                paymentMethodCell(type: .payPal, logo: Image("payPal"))
                paymentMethodCell(type: .mastercard, logo: Image("mastercard"))
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }

    private func paymentMethodCell(type: CheckoutPaymentVM.PaymentMethod, logo: Image, title: String? = nil) -> some View {
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
            withAnimation {
                viewModel.selectedMethod = type
            }
        }
    }
}

struct PaymentMethodSelector_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutPaymentSheet()
    }
}
