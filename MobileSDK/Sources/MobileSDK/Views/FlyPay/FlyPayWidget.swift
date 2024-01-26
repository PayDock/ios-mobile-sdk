//
//  FlyPayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI

public struct FlyPayWidget: View {

    @StateObject private var viewModel: FlyPayVM

    public init(flyPayToken: @escaping (_ flyPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<Void, FlyPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: FlyPayVM(flyPayToken: flyPayToken, completion: completion))
    }

    public var body: some View {
        LargeButton(
            title: "Pay with",
            image: Image("flypay", bundle: Bundle.module),
            imageLocation: .right,
            backgroundColor: .primaryColor) {
                viewModel.handleButtonTap()
            }
            .sheet(isPresented: $viewModel.showWebView) {
                NavigationStack {
                    FlyPayWebView(
                        flyPayOrderId: viewModel.flyPayOrderId,
                        onApprove: {
                            viewModel.handleSuccess()
                        },
                        onFailure: { error in
                            viewModel.handleFailure(error: error)
                        })
                    .navigationTitle("Checkout with FlyPay")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct FlyPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        FlyPayWidget(flyPayToken: { _ in }, completion: { _ in })
    }
}
