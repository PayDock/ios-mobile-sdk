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
                PayPalSavePaymentSourceWidget(config: PayPalVaultConfig(accessToken: "", gatewayId: "")) { result in
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
}

struct PayPalVaultWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalVaultWidgetView()
    }
}
