//
//  AfterpayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI
import Afterpay

public struct AfterpayWidget: View {

    @StateObject private var viewModel: AfterpayVM
    @State var appearance: AfterpayWidgetAppearance

    public init(viewState: ViewState? = nil,
                configuration: AfterpaySdkConfig,
                appearance: AfterpayWidgetAppearance = AfterpayWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
                selectAddress: ((_ address: ShippingAddress, _ provideShippingOptions: ([ShippingOption]) -> Void) -> Void)?,
                selectShippingOption: ((_ shippingOption: ShippingOption,
                                        _ provideShippingOptionUpdateResult: (ShippingOptionUpdate?) -> Void) -> Void)?,
                completion: @escaping (Result<ChargeResponse, AfterpayError>) -> Void) {
        _viewModel = StateObject(
            wrappedValue: AfterpayVM(
                viewState: viewState ?? ViewState(state: .none),
                configuration: configuration,
                tokenRequest: tokenRequest,
                selectAddress: selectAddress,
                selectShippingOption: selectShippingOption,
                loadingDelegate: loadingDelegate,
                eventDelegate: eventDelegate,
                completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        AfterpayPaymentButton(
            colorScheme: appearance.colorScheme,
            type: appearance.type,
            action: {
                viewModel.handleAfterpayButtonTapAnalytics()
                viewModel.handleButtonTap()
            })
        .modifier(ActivityIndicatorModifier(appearance: appearance.loader, isLoading: viewModel.isLoading))
        .accessibilityHint("Initiates payment using Afterpay.")
    }
}

struct AfterpayWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayWidget(
            configuration: .init(
                environment: .sandbox,
                options: .init())) { _ in

                } selectAddress: { _, _ in

                } selectShippingOption: { _, _ in

                } completion: { _ in

                }
    }
}
