//
//  AfterPayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI
import Afterpay

public struct AfterPayWidget: View {
    @StateObject private var viewModel: AfterPayVM

    public init(afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<String, AfterPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: AfterPayVM(afterPayToken: afterPayToken, completion: completion))
    }

    public var body: some View {
        AfterpayPaymentButton(action: {
            viewModel.handleButtonTap()
        })
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onChange(of: viewModel.showWebView) { newValue in
            viewModel.presentAfterpay(self)
        }
    }
}

struct AfterPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayWidget(afterPayToken: { _ in }, completion: { _ in })
    }
}
