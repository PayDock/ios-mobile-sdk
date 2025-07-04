//
//  CustomPaddingModifier.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 08.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct CustomPaddingModifier: ViewModifier {
    let padding: Padding

    func body(content: Content) -> some View {
        content
            .padding(.top, padding.top)
            .padding(.leading, padding.leading)
            .padding(.bottom, padding.bottom)
            .padding(.trailing, padding.trailing)
    }
}
