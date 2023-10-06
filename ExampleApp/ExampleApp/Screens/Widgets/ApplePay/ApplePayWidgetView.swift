//
//  ApplePayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 04.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ApplePayWidgetView: View {

    @StateObject private var viewModel = ApplePayWidgetVM()
    @State var isSheetPresented = false
    // TODO: - Update to response model after other tickets are completed
    @State var onCompletion: ChargeResponse?
    @State var onFailure: ApplePayError?

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                    Button("Launch Apple Pay sheet") {
                        isSheetPresented = true
                    }
                    .disabled(!viewModel.applePayButtonEnabled)
                    .padding()
                    ApplePaySheetView(
                        isPresented: $isSheetPresented,
                        applePayRequest: viewModel.getApplePayRequest(),
                        onCompletion: $onCompletion,
                        onFailure: $onFailure)
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

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
