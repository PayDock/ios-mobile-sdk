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
    @State var isSheetPresented = false
    @State var onCompletion: ChargeResponse?
    @State var onFailure: PayPalError?

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                    Button("Launch PayPal sheet") {
                        isSheetPresented = true
                    }
                    .disabled(!viewModel.payPalButtonEnabled)
                    .padding()
                    if !viewModel.walletToken.isEmpty {
                        PayPalSheetView(
                            isPresented: $isSheetPresented,
                            payPalToken: viewModel.walletToken,
                            onCompletion: $onCompletion,
                            onFailure: $onFailure)
                    }
                    Spacer()
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .onAppear {
            viewModel.initializeWalletCharge()
        }
    }
}

struct PayPalWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
