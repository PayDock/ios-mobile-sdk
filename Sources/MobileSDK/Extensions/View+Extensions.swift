//
//  View+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

extension View {

    func animatableFont(size: CGFloat) -> some View {
      modifier(AnimatableCustomFontModifier(size: size))
    }

    func customFont(_ size: Fonts.Size) -> some View {
        return self.modifier(ScaledFont(size: size.rawValue))
    }

}

