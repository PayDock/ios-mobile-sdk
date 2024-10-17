//
//  PayPalVaultWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 14.10.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PayPalVaultWidgetView: View {

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalSavePaymentSourceWidget(config: getConfig()) { result in
                    switch result {
                    case let .success(payPalVaultResult):
                        print(payPalVaultResult.token)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
            .background(.white)
        }
    }
    
    private func getConfig() -> PayPalVaultConfig {
        let accessToken = ProjectEnvironment.shared.getAccessToken()
        let gatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
        let config = PayPalVaultConfig(accessToken: accessToken, gatewayId: gatewayId)
        return config
    }
}

struct PayPalVaultWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalVaultWidgetView()
    }
}
