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
    @State var buttonWidth: CGFloat

    public init(configuration: AfterpaySdkConfig,
                afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
                buttonWidth: CGFloat,
                completion: @escaping (Result<String, AfterPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: AfterPayVM(afterPayToken: afterPayToken, completion: completion))
        self.buttonWidth = buttonWidth
    }

    public var body: some View {
        HStack {
            Spacer()
            AfterpayPaymentButton(width: buttonWidth, action: {
                viewModel.handleButtonTap()
            })
            .frame(width: buttonWidth, height: buttonWidth * 0.15)
            Spacer()
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .onChange(of: viewModel.showWebView) { newValue in
            viewModel.presentAfterpay(self)
        }
    }
}

struct AfterPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterPayWidget(afterPayToken: { _ in }, buttonWidth: 320, completion: { _ in })
    }
}
