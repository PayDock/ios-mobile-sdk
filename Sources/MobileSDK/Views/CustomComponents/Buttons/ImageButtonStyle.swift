//
//  ImageButtonStyle.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 13.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {

    let appearance: Theme.ButtonLoader
    var isDisabled: Bool = false

    init(appearance: Theme.ButtonLoader = Theme.ButtonLoader(),
         isDisabled: Bool = false) {
        self.appearance = appearance
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .opacity(isDisabled || configuration.isPressed ? 0.8 : 1.0)
    }
}
