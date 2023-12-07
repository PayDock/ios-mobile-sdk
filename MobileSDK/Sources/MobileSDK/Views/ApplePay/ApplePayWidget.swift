//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM

    public init(applePayRequest: ApplePayRequest,
                completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            applePayRequest: applePayRequest,
            completion: completion))
    }

    var body: some View {
        ApplePayButton {
            viewModel.startPayment()
        }
        .padding()
    }

}

struct ApplePayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidget(
            applePayRequest: .init(token: "asdf", request: PKPaymentRequest()), completion: { _ in })
    }
}
