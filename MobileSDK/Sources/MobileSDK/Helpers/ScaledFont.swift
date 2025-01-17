//
//  ScaledFont.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//  Created by Domagoj Grizelj on 07.01.2025..
//

import SwiftUI

struct ScaledFont: ViewModifier {
    @Environment(\.dynamicTypeSize) var sizeCategory
    var size: Double

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(Appearance.shared.fontName, size: scaledSize))
    }
}
