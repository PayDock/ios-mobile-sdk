//
//  PayPalWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI
import PaymentButtons
import PayPalWebPayments

public struct PayPalWidget: View {
    @StateObject private var viewModel: PayPalVM
    @State var apparance: PayPalWidgetAppearance

    public init(viewState: ViewState? = nil,
                appearance: PayPalWidgetAppearance = PayPalWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
                completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalVM(
            viewState: viewState ?? ViewState(state: .none),
            tokenRequest: tokenRequest,
            loadingDelegate: loadingDelegate,
            completion: completion))
        self.apparance = appearance
    }

    public var body: some View {
        PayPalButton.Representable(
            insets: apparance.buttonInsets,
            color: apparance.buttonColor,
            edges: apparance.buttonEdges,
            size: apparance.buttonSize,
            label: apparance.buttonLabel) {
                viewModel.handleButtonTap()
            }
            .disabled(viewModel.viewState.isDisabled)
            .overlay {
                if viewModel.isLoading {
                    GeometryReader { geometry in
                        ProgressView()
                            .tint(getProgressViewTint())
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            .background(getProgressViewBackground())
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showWebView, content: {
                webViewSheetContent
            })
    }

    private func getProgressViewBackground() -> Color {
        switch apparance.buttonColor {
        case .gold: return Color(hex: "#FFC439")
        case .white: return Color(hex: "#FFFFFF")
        case .black: return Color(hex: "#000000")
        case .silver: return Color(hex: "#EEEEEE")
        case .blue: return Color(hex: "#0070BA")

        }
    }

    private func getProgressViewTint() -> Color {
        switch apparance.buttonColor {
        case .blue, .black: return .white
        case .white, .gold, .silver: return .black
        }
    }

//    private var payPalDisabledButton: some View {
//        SDKButton(
//            title: "",
//            isLoading: viewModel.isLoading && viewModel.showLoaders,
//            style: .fill(FillButtonStyle(appearance: getButtonAppearance(), isDisabled: viewModel.viewState.isDisabled)
//                        )
//        ) {}
//    }
//
//    private var payPalButton: some View {
//        SDKButton(
//            title: "",
//            image: Image("pay-pal", bundle: Bundle.module),
//            style: .fill(FillButtonStyle(
//                appearance: getButtonAppearance(),
//                isDisabled: viewModel.viewState.isDisabled)
//            )) {
//                viewModel.handleButtonTap()
//            }
//            .accessibilityHint("Initiates payment using PayPal.")
//    }

    private func getButtonAppearance() -> Theme.ButtonAppearance {
        let colors = Theme.ButtonColors(background: Color(red: 1.0, green: 0.76, blue: 0.30))
        let appearance = Theme.ButtonAppearance(colors: colors, loader: apparance.loader)
        return appearance
    }

    private var webViewSheetContent: some View {
        NavigationStack {
            if let url = viewModel.payPalUrl {
                PayPalWebView(url: url, onApprove: { paymentMethodId, payerId in
                    viewModel.capturePayPalPayment(paymentMethodId: paymentMethodId, payerId: payerId)
                }, onFailure: { error in
                    viewModel.handleWebViewFailure(error)
                })
                .navigationTitle("Checkout with PayPal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.showCancelConfirmation = true
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.title)
                                .imageScale(.small)
                        })
                    }
                }
            }
        }
        .interactiveDismiss(canDismissSheet: false) {
            viewModel.showCancelConfirmation = true
        }
        .confirmationDialog("Are you sure you want to cancel?",
                            isPresented: $viewModel.showCancelConfirmation,
                            titleVisibility: .visible, actions: {
            Button("Yes", role: .destructive) {
                viewModel.showWebView = false
                viewModel.handleSheetCancellation()
            }
            Button("No", role: .cancel) {}
        })
    }
}

struct PayPalWidget_Previews: PreviewProvider {
    static var previews: some View {
        PayPalWidget(loadingDelegate: nil) { _ in } completion: { _ in }
    }
}
