//
//  PayPalSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.10.2023..
//

import SwiftUI

public struct PayPalSheetView: View {

    @State var payPalToken: String
    @Binding var isPresented: Bool
    @Binding var onCompletion: ChargeResponse?
    @Binding var onFailure: PayPalError?

    public init(isPresented: Binding<Bool>,
                payPalToken: String,
                onCompletion: Binding<ChargeResponse?>,
                onFailure: Binding<PayPalError?>) {
        self._isPresented = isPresented
        self.payPalToken = payPalToken
        self._onCompletion = onCompletion
        self._onFailure = onFailure
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            PayPalView(
                payPalToken: payPalToken,
                onCompletion: $onCompletion,
                onFailure: $onFailure)
        }
    }
}

struct PayPalSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalSheetView(isPresented: .constant(true), payPalToken: "", onCompletion: .constant(ChargeResponse(status: "", amount: 10, currency: "")), onFailure: .constant(.requestFailed))
    }
}
