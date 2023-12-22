//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

public struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM

    public init(applePayRequestHandler: @escaping (_ applePayRequest: @escaping (ApplePayRequest) -> Void) -> Void,
                completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            applePayRequestHandler: applePayRequestHandler,
            completion: completion))
    }

    public var body: some View {
        ApplePayButton {
            viewModel.handleButtonTap()
        }
        .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
        .padding()
    }

}

struct ApplePayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidget(applePayRequestHandler: { _ in }, completion: { _ in })
    }
}
