//
//  PayPalSavePaymentSourceWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import SwiftUI

public struct PayPalSavePaymentSourceWidget: View {
    @StateObject private var viewModel: PayPalSavePaymentSourceVM
    @State private var appearance: PayPalVaultAppearance

    public init(viewState: ViewState? = nil,
                config: PayPalVaultConfig,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                appearance: PayPalVaultAppearance = PayPalVaultAppearance(),
                completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalSavePaymentSourceVM(
            viewState: viewState ?? ViewState(),
            config: config,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        SDKButton(
            title: appearance.actionButton.text,
            isLoading: viewModel.isLoading && viewModel.showLoaders,
            style: .custom(CustomButtonStyle(appearance: appearance.actionButton, isDisabled: viewModel.viewState.isDisabled)),
            shouldTemplate: true) {
                viewModel.initializePayPalSDK()
                viewModel.handleButtonTapAnalytics()
            }
    }
}

struct PayPalSavePaymentSourceWidget_Previews: PreviewProvider {
    static var previews: some View {
        PayPalSavePaymentSourceWidget(config: .init(accessToken: "", gatewayId: "")) { _ in }
    }
}
