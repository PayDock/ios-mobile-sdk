//
//  View+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

extension View {
    
    func bottomSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        overlay(
            BottomSheetView(isPresented: isPresented, content: content)
        )
    }

    func animatableFont(size: CGFloat) -> some View {
      modifier(AnimatableCustomFontModifier(size: size))
    }

    func customFont(_ size: Fonts.AcidGrotesk.Size, weight: Fonts.AcidGrotesk = .normal) -> some View {
        font(.custom(weight.rawValue, size: size.rawValue))
    }

}
