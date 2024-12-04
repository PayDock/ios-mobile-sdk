//
//  PayPalWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI

public struct PayPalWidget: View {
    @StateObject private var viewModel: PayPalVM

<<<<<<< HEAD
    public init(options: WidgetOptions? = nil,
=======
    public init(viewState: ViewState? = nil,
>>>>>>> main
                loadingDelegate: WidgetLoadingDelegate? = nil,
                payPalToken: @escaping (_ payPalToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalVM(
<<<<<<< HEAD
            options: options ?? WidgetOptions(state: .none),
=======
            viewState: viewState ?? ViewState(state: .none),
>>>>>>> main
            payPalToken: payPalToken,
            loadingDelegate: loadingDelegate,
            completion: completion)
        )
    }

    public var body: some View {
        if (viewModel.isLoading && viewModel.showLoaders) {
            SDKButton(
                title: "",
                isLoading: viewModel.isLoading && viewModel.showLoaders,
                style: .fill(FillButtonStyle(
                        backgroundColor: Color(red: 1.0, green: 0.76, blue: 0.30),
                        foregroundColor: .black,
<<<<<<< HEAD
                        isDisabled: viewModel.options.isDisabled
=======
                        isDisabled: viewModel.viewState.isDisabled
>>>>>>> main
                    )
                )
            ) {}
        } else {
            SDKButton(
                title: "",
                image: Image("pay-pal", bundle: Bundle.module),
                style: .fill(FillButtonStyle(
                        backgroundColor: Color(red: 1.0, green: 0.76, blue: 0.30),
<<<<<<< HEAD
                        isDisabled: viewModel.options.isDisabled
=======
                        isDisabled: viewModel.viewState.isDisabled
>>>>>>> main
                    )
                )) {
                    viewModel.handleButtonTap()
                }
                .sheet(isPresented: $viewModel.showWebView, onDismiss: {
                    if viewModel.sheetAction == .nothing {
                        viewModel.handleSheetCancellation()
                    }
                }) {
                    NavigationStack {
                        if let url = viewModel.payPalUrl {
                            PayPalWebView(url: url, onApprove: { paymentMethodId, payerId in
                                viewModel.capturePayPalPayment(paymentMethodId: paymentMethodId, payerId: payerId)
                            }, onFailure: { error in
                                viewModel.handleWebViewFailure(error)
                            })
                            .navigationTitle("Checkout with PayPal")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
        }
    }
}

struct PayPalWidget_Previews: PreviewProvider {
    static var previews: some View {
        PayPalWidget(loadingDelegate: nil, payPalToken: { _ in }, completion: { _ in })
    }
}
