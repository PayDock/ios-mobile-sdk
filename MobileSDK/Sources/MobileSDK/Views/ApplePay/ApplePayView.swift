//
//  ApplePayView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI

struct ApplePayView: View {

    @Binding private var onCompletion: String

    public init(onCompletion: Binding<String>) {
        self._onCompletion = onCompletion
    }

    var body: some View {
        ApplePayButton {
            
        }
        .padding()
    }
}

#Preview {
    ApplePayView(onCompletion: .constant("OnCompletionString"))
}
