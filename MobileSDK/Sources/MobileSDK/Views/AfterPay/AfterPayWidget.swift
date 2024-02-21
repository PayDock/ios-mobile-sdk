//
//  AfterPayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI

public struct AfterPayWidget: View {

    @StateObject private var viewModel: AfterPayVM

    public init(afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<Void, AfterPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: AfterPayVM(afterPayToken: afterPayToken, completion: completion))
    }

    public var body: some View {
        LargeButton(
            title: "Afterpay",
            image: Image("flypay", bundle: Bundle.module),
            imageLocation: .right,
            backgroundColor:  Color(red: 0.00, green: 0.48, blue: 0.75)) {
                viewModel.handleButtonTap()
            }
            .sheet(isPresented: $viewModel.showWebView) {
                NavigationStack {
                    AfterPayWebView(
                        afterPayOrderId: viewModel.afterPayOrderId,
                        onApprove: {
                            viewModel.handleSuccess()
                        },
                        onFailure: { error in
                            viewModel.handleFailure(error: error)
                        })
                    .navigationTitle("Checkout with AfterPay")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct AfterPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayWidget(afterPayToken: { _ in }, completion: { _ in })
    }
}
