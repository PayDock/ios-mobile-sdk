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

    var body: some View {
        NavigationStack {
            ScrollView {
                ApplePayWidget { onApplePayButtonTap in
                    viewModel.initializeWalletCharge(completion: onApplePayButtonTap)
                } completion: { result in
                    switch result {
                    case .success(let chargeResponse): break
                    case .failure(let error): break
                    }
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
