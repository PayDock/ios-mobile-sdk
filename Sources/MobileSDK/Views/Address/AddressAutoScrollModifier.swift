//
//  AddressAutoScrollModifier.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.07.2025..
//

import SwiftUI

struct AddressAutoScrollModifier: ViewModifier {
    let textFieldInFocus: AddressFormManager.AddressFocusable?
    let proxy: ScrollViewProxy

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: textFieldInFocus) { _, newValue in
                    if let focusedField = newValue {
                        scrollToField(focusedField, proxy: proxy)
                    }
                }
        } else {
            content
        }
    }

    private func scrollToField(_ field: AddressFormManager.AddressFocusable, proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }
}
