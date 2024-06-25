//
//  AfterpayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI
import Afterpay

public struct AfterpayWidget: View {
    @StateObject private var viewModel: AfterpayVM
    @State var buttonWidth: CGFloat

    public init(configuration: AfterpaySdkConfig,
                afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
                selectAddress: ((_ address: ShippingAddress, _ provideShippingOptions: ([ShippingOption]) -> Void) -> Void)?,
                selectShippingOption: ((_ shippingOption: ShippingOption, _ provideShippingOptionUpdateResult: (ShippingOptionUpdate?) -> Void) -> Void)?,
                buttonWidth: CGFloat,
                completion: @escaping (Result<ChargeResponse, AfterpayError>) -> Void) {
        _viewModel = StateObject(
            wrappedValue: AfterpayVM(
                configuration: configuration,
                afterPayToken: afterPayToken,
                selectAddress: selectAddress,
                selectShippingOption: selectShippingOption,
                completion: completion))
        self.buttonWidth = buttonWidth
    }

    public var body: some View {
        HStack {
            Spacer()
            AfterpayPaymentButton(
                width: buttonWidth,
                config: viewModel.configuration.buttonTheme,
                action: {
                    viewModel.handleButtonTap()
            })
            .frame(width: buttonWidth, height: buttonWidth * 0.15)
            Spacer()
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
}

struct AfterpayWidget_Previews: PreviewProvider {
    static var previews: some View {
        AfterpayWidget(
            configuration: .init(
                buttonTheme: .init(),
                config: .init(maximumAmount: "100.0", currency: "AUD"),
                environment: .sandbox,
                options: .init()),
            afterPayToken: { _ in },
            selectAddress: { address, provideShippingOptions in },
            selectShippingOption: { shippingOption, provideShippingOptionUpdateResult in },
            buttonWidth: 320,
            completion: { _ in })
    }
}
