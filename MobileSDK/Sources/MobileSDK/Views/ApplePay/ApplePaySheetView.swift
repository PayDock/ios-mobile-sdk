//
//  ApplePaySheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI

public struct ApplePaySheetView: View {

    @Binding var isPresented: Bool
    @Binding var onCompletion: String

    public init(isPresented: Binding<Bool>,
                onCompletion: Binding<String>) {
        self._isPresented = isPresented
        self._onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            ApplePayView(onCompletion: $onCompletion)
        }
    }
}

#Preview {
    ApplePaySheetView(isPresented: .constant(true), onCompletion: .constant("Data"))
}
