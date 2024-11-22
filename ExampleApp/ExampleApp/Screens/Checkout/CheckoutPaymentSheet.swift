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
    private let onCloseSheet: () -> Void

    init(viewModel: CheckoutPaymentVM = CheckoutPaymentVM(),
         onCloseSheet: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCloseSheet = onCloseSheet
    }

    var body: some View {
        VStack {
            title()
            selector()
            switch viewModel.selectedMethod {
            case .card:
                VStack {
                    CardDetailsWidget(gatewayId: nil,
                                      accessToken: ProjectEnvironment.shared.getAccessToken(),
                                      actionText: "Pay",
                                      showCardTitle: false,
                                      collectCardholderName: false,
                                      allowSaveCard: SaveCardConfig(consentText: "Save payment details", privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(privacyPolicyText: "Read our privacy policy", privacyPolicyURL: "https://www.google.com")),
                                      completion: { result in
                        switch result {
                        case .success(let result): viewModel.payWithCard(result.token)
                        case .failure: break
                        }
                    })
                    .frame(height: 240)
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
                .frame(height: 48.0)
                .padding()

            case .afterpay:
                AfterpayWidget(
                    configuration: viewModel.getAfterpayConfig(),
                    afterPayToken: { onAfterpayButtonTap in
                        viewModel.initializeAfterpayWalletCharge(completion: onAfterpayButtonTap)
                    }, 
                    selectAddress: { address, provideShippingOptions in
                        // Provide shipping options based on user selected address if needed
                        // Check AfterpayWidget example for more details
                        provideShippingOptions(viewModel.getShippingOptions())
                    },
                    selectShippingOption: { shippingOption, provideShippingOptionUpdateResult in
                        // Provide shipping update if needed based on the selected shipping option
                        // Check AfterpayWidget example for more details
                        provideShippingOptionUpdateResult(viewModel.getShippingOptionUpdate())
                    },
                    buttonWidth: 320) { result in
                        switch result {
                        case .success:
                            viewModel.alertTitle = "Success"
                            viewModel.alertMessage = "Charge successful"
                            viewModel.showAlert = true
                        case .failure:
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "Charge failed"
                            viewModel.showAlert = true
                        }
                    }
                    .padding()

            case .mastercard:
                Button("Checkout with Click to Pay") {
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
                            ClickToPayWidget(
                                serviceId: ProjectEnvironment.shared.getMastercardServiceId() ?? "",
                                accessToken: ProjectEnvironment.shared.getAccessToken(),
                                meta: nil) { result in
                                    switch result {
                                    case .success(let result):
                                        viewModel.handleMastercardResult(result)
                                        
                                    case .failure(let error):
                                        viewModel.alertMessage = error.localizedDescription
                                        viewModel.showAlert = true
                                    }
                                }
                        }
                        .navigationTitle("Checkout with Click to Pay")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                })
            }
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {
            Button("OK") {
              onCloseSheet()
           }
        }, message: {
            Text(viewModel.alertMessage)
        })
        .sheet(isPresented: $viewModel.show3dsWebView, onDismiss: { }) {
            NavigationStack {
                VStack {
                    ThreeDSWidget(
                        token: viewModel.token3DS,
                        baseURL: viewModel.getBaseUrl(),
                        completion: { result in
                            switch result {
                            case .success(let result):
                                viewModel.handle3dsEvent(result)
                                
                            case .failure(let error):
                                viewModel.alertMessage = error.localizedDescription
                                viewModel.showAlert = true
                            }
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
                paymentMethodCell(type: .afterpay, logo: Image("afterpay"))
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
        CheckoutPaymentSheet(onCloseSheet: {})
    }
}
