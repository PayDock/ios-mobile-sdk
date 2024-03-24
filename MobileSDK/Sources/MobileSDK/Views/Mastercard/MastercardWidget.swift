//
//  MastercardWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

public struct MastercardWidget: View {

    @StateObject private var viewModel: MastercardVM

    public init() {
        _viewModel = StateObject(wrappedValue: MastercardVM())
    }

    public var body: some View {
        LargeButton(
            title: "Pay with Mastercard",
            image: Image("", bundle: Bundle.module),
            imageLocation: .right,
            backgroundColor:  Color(red: 0.00, green: 0.48, blue: 0.75)) {
                viewModel.showWebView = true
            }
            .sheet(isPresented: $viewModel.showWebView) {
                NavigationStack {
                    MastercardWebView(completion: { _ in
                        
                    })
                    .navigationTitle("Checkout with Mastercard")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct MastercardWidget_Previews: PreviewProvider {
    static var previews: some View {
        MastercardWidget()
    }
}
