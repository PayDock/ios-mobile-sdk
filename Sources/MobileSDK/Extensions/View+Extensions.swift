//
//  View+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

extension View {

    func animatableFont(size: CGFloat, fontName: String) -> some View {
        modifier(AnimatableCustomFontModifier(size: size, fontName: fontName))
    }

    func customPadding(_ padding: Padding) -> some View {
        self.modifier(CustomPaddingModifier(padding: padding))
    }

    @ViewBuilder
    func onConditionalKeyPress(key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onKeyPress(.tab, action: {
                action()
                return .handled
            })
        } else {
            self
        }
    }

    @ViewBuilder
    func conditionalFocusable() -> some View {
        if #available(iOS 17.0, *) {
            self.focusable()
        } else {
            self
        }
    }

    func interactiveDismiss(canDismissSheet: Bool, onDismissalAttempt: (() -> Void)? = nil) -> some View {
        DismissDetectingView(
            view: self,
            canDismissSheet: canDismissSheet,
            onDismissalAttempt: onDismissalAttempt
        ).edgesIgnoringSafeArea(.all)
    }
}
