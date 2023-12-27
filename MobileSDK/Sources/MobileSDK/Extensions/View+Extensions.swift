//
//  View+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

extension View {

    func animatableFont(size: CGFloat) -> some View {
      modifier(AnimatableCustomFontModifier(size: size))
    }

    func customFont(_ size: Fonts.Size) -> some View {
        font(.custom(Appearance.shared.fontName, size: size.rawValue))
    }

}

