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
    @Binding var onCompletion: ChargeResponse?
    @Binding var onFailure: ApplePayError?

    public init(isPresented: Binding<Bool>,
                applePayRequest: ApplePayRequest,
                onCompletion: Binding<ChargeResponse?>,
                onFailure: Binding<ApplePayError?>) {
        self._isPresented = isPresented
        self.applePayRequest = applePayRequest
        self._onCompletion = onCompletion
        self._onFailure = onFailure
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            ApplePayView(
                applePayRequest: applePayRequest,
                onCompletion: $onCompletion,
                onFailure: $onFailure)
        }
    }
}

//#Preview {
//    ApplePaySheetView(isPresented: .constant(true), onCompletion: .constant("Data"))
//}
