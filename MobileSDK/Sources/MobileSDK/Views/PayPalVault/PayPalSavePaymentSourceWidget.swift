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
                completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalSavePaymentSourceVM(config: config, completion: completion))
    }

    public var body: some View {
        SDKButton(
            title: "Link PayPal account",
            image: Image("link", bundle: Bundle.module),
            style: .outline(OutlineButtonStyle())) {
                // TODO: - Add handle on tap
            }
            .padding()
            .customFont(.body)
    }
}

struct PayPalSavePaymentSourceWidget_Previews: PreviewProvider {
    static var previews: some View {
        PayPalSavePaymentSourceWidget(config: .init(accessToken: "", gatewayId: "")) { _ in }
    }
}
