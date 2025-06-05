//
//  ImageButtonStyle.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 13.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {

    let appearance: Theme.ButtonAppearance
    var isDisabled: Bool = false

    init(appearance: Theme.ButtonAppearance = Theme.ButtonAppearance(),
         isDisabled: Bool = false) {
        self.appearance = appearance
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .opacity(isDisabled || configuration.isPressed ? 0.8 : 1.0)
    }
}
