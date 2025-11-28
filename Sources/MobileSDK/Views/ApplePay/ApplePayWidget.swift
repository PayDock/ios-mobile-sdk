//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

public struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM
    @State var appearance: ApplePayWidgetAppearance

    public init(appearance: ApplePayWidgetAppearance = ApplePayWidgetAppearance(),
                eventDelegate: WidgetEventDelegate? = nil,
                createPaymentRequest: @escaping (
                    _ createPaymentRequestResult: @escaping (
                        Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) -> Void,
                completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            eventDelegate: eventDelegate,
            createPaymentRequest: createPaymentRequest,
            completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        ApplePayButton(appearance: appearance) {
            viewModel.handleButtonTap()
            viewModel.handleApplePayTapAnalytics()
        }
    }
}

struct ApplePayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidget(createPaymentRequest: { _ in }, completion: { _ in })
    }
}
