//
//  AfterPayNativeWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.02.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import Afterpay

public struct AfterPayNativeWidget: View {

    @StateObject private var viewModel: AfterPayNativeVM

    public init(afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<Void, AfterPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: AfterPayNativeVM(afterPayToken: afterPayToken, completion: completion))
    }

    public var body: some View {
        LargeButton(
            title: "Afterpay Native",
            image: nil,
            imageLocation: .right,
            backgroundColor:  Color(red: 0.00, green: 0.48, blue: 0.75)) {
                viewModel.handleButtonTap()
            }
            .afterpayCheckout(url: $viewModel.webUrl, completion: { result in
                print(result)
            })
            .sheet(isPresented: $viewModel.showWebView) {
//                NavigationStack {
//                    AfterPayWebView(
//                        afterPayOrderId: viewModel.afterPayOrderId,
//                        onApprove: {
//                            viewModel.handleSuccess()
//                        },
//                        onFailure: { error in
//                            viewModel.handleFailure(error: error)
//                        })
//                    .navigationTitle("Checkout with AfterPay")
//                    .navigationBarTitleDisplayMode(.inline)
//                }
            }
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct AfterPayNativeWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayNativeWidget(afterPayToken: { _ in }, completion: { _ in })
    }
}
