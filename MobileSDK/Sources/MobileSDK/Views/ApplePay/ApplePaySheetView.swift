//
//  ApplePaySheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI

public struct ApplePaySheetView: View {

    @State var applePayRequest: ApplePayRequest

    @Binding var isPresented: Bool
    private let completion: (Result<ChargeResponse, ApplePayError>) -> Void

    public init(isPresented: Binding<Bool>,
                applePayRequest: ApplePayRequest,
                completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        self._isPresented = isPresented
        self.applePayRequest = applePayRequest
        self.completion = completion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            ApplePayWidget(
                applePayRequest: applePayRequest,
                completion: completion)
        }
    }
}

struct ApplePaySheetView_Previews: PreviewProvider {
    static var previews: some View {
            ApplePaySheetView(
                isPresented: .constant(true),
                applePayRequest: ApplePayRequest(
                    token: "",
                    request: MobileSDK.createApplePayRequest(
                        amount: 10,
                        amountLabel: "AUD",
                        countryCode: "AU",
                        currencyCode: "AUD",
                        merchantIdentifier: "")),
                completion: { _ in })
    }
}
