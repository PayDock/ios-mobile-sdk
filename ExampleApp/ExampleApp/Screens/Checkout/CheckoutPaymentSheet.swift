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

    init(onCloseSheet: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CheckoutPaymentVM())
        self.onCloseSheet = onCloseSheet
    }

    var body: some View {
        VStack {
            title()
            selector()
            switch viewModel.selectedMethod {
            case .card: cardWidget
            case .applePay: applePayWidget
            case .payPal: payPalWidget
            case .afterpay: afterpayWidget
            case .mastercard: clickToPayWidget
            case .colesPay: colesPayWidget
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
        .sheet(isPresented: $viewModel.show3dsWebView, onDismiss: {}, content: {
            NavigationStack {
                VStack {
                    Integrated3DSWidget(
                        config: .init(token: viewModel.token3DS),
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
        })
    }

    // MARK: - Widget views

    private var cardWidget: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 20.0)
                    CardDetailsWidget(viewState: viewModel.viewState,
                                      config: CardDetailsWidgetConfig(
                                        gatewayId: nil,
                                        accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                                        actionText: "Pay",
                                        showCardTitle: false,
                                        collectCardholderName: false,
                                        allowSaveCard: SaveCardConfig(
                                            consentText: "Save payment details",
                                            privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                                                privacyPolicyText: "Read our privacy policy",
                                                privacyPolicyURL: "https://www.google.com")
                                        )
                                      ),
                                      loadingDelegate: viewModel,
                                      completion: { result in
                        switch result {
                        case .success(let result):
                            viewModel.payWithCard(result.token)
                        case .failure(let error):
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = error.customMessage
                            viewModel.showAlert = true
                        }
                    })
                    Spacer()
                }
            }
        }
    }

    private var applePayWidget: some View {
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
        .frame(height: 50.0)
        .padding()
    }

    private var payPalWidget: some View {
        HStack {
            PayPalWidget(
                viewState: viewModel.viewState,
                config: viewModel.getPayPalConfig(),
                loadingDelegate: viewModel) { onPayPalButtonTap in
                viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
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
            .frame(height: 48.0)
            .padding()
        }
    }

    private var afterpayWidget: some View {
        AfterpayWidget(
            configuration: viewModel.getAfterpayConfig(),
            tokenRequest: { tokenResult in
                viewModel.initializeAfterpayWalletCharge(completion: tokenResult)
            },
            selectAddress: { _, provideShippingOptions in
                // Provide shipping options based on user selected address if needed
                // Check AfterpayWidget example for more details
                provideShippingOptions(viewModel.getShippingOptions())
            },
            selectShippingOption: { _, provideShippingOptionUpdateResult in
                // Provide shipping update if needed based on the selected shipping option
                // Check AfterpayWidget example for more details
                provideShippingOptionUpdateResult(viewModel.getShippingOptionUpdate())
            }, completion: { result in
                switch result {
                case .success:
                    viewModel.alertTitle = "Success"
                    viewModel.alertMessage = "Charge successful"
                    viewModel.showAlert = true
                case .failure(let error):
                    viewModel.alertTitle = "Error"
                    viewModel.alertMessage = error.customMessage
                    viewModel.showAlert = true
                }
            })
            .padding()
    }

    private var clickToPayWidget: some View {
        Button("Checkout with Click to Pay") {
            viewModel.showMastercardWebView = true
        }
        .foregroundStyle(.white)
        .font(Font.system(size: 16, weight: .semibold))
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(Color.defaultPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding()
        .sheet(isPresented: $viewModel.showMastercardWebView, content: {
            NavigationStack {
                VStack {
                    ClickToPayWidget(
                        config: .init(
                            serviceId: ProjectEnvironment.shared.getMastercardServiceId() ?? "",
                            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(), meta: nil)) { result in
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

    private var colesPayWidget: some View {
        ScrollView {
            ColesPayWidget(
                viewState: viewModel.viewState,
                loadingDelegate: viewModel,
                config: .init(clientId: ProjectEnvironment.shared.getColesPayClientId() ?? "")) { tokenResult in
                    viewModel.initializeWalletChargeColesPay(completion: tokenResult)
                } completion: { result in
                    switch result {
                    case .success: viewModel.handleSuccess()
                    case .failure(let error): viewModel.handleError(error: error)
                    }
                }
                .padding()
        }
    }

    // MARK: - Helpers

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
                paymentMethodCell(type: .colesPay, logo: Image("coles-pay"), resizable: true)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }

    private func paymentMethodCell(type: CheckoutPaymentVM.PaymentMethod,
                                   logo: Image, resizable: Bool = false,
                                   title: String? = nil) -> some View {
        HStack {
            if resizable {
                logo
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            } else {
                logo
            }

            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.defaultText)
            }
        }
        .frame(width: 90, height: 49)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    type == viewModel.selectedMethod ? Color.defaultPrimary : .black,
                    lineWidth: type == viewModel.selectedMethod ? 2 : 1/3
                )
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
