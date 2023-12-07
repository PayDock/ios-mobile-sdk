//
//  PayPalWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 26.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct PayPalWidgetView: View {

    @StateObject private var viewModel = PayPalWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                PayPalWidget { onPayPalButtonTap in
                    viewModel.initializeWalletCharge(completion: onPayPalButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse): break
                    case .failure(let error): break
                    }
                }
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct PayPalWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
