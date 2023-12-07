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
    private var completion: (Result<ChargeResponse, PayPalError>) -> Void

    public init(isPresented: Binding<Bool>,
                payPalToken: String,
                completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self._isPresented = isPresented
        self.payPalToken = payPalToken
        self.completion = completion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            PayPalWidget(
                payPalToken: payPalToken,
                completion: completion)
        }
    }
}

struct PayPalSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PayPalSheetView(
            isPresented: .constant(true),
            payPalToken: "",
            completion: {_ in })
    }
}
