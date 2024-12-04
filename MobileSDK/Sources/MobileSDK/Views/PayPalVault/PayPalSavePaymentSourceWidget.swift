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

    public init(config: PayPalVaultConfig,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalSavePaymentSourceVM(
            config: config,
            loadingDelegate: loadingDelegate,
            completion: completion)
        )
    }

    public var body: some View {
        SDKButton(
            title: viewModel.actionText,
            image: Image("link", bundle: Bundle.module),
            isLoading: viewModel.isLoading && viewModel.showLoaders,
            style: .outline(OutlineButtonStyle(isDisabled: viewModel.config.viewState.isDisabled))) {
                viewModel.initializePayPalSDK()
            }
            .customFont(.body)
    }
}

struct PayPalSavePaymentSourceWidget_Previews: PreviewProvider {
    static var previews: some View {
        PayPalSavePaymentSourceWidget(config: .init(accessToken: "", gatewayId: "")) { _ in }
    }
}
