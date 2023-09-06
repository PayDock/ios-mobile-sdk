//
//  Text+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

extension Text {

    func customFont(_ size: Fonts.Size) -> Text {
        font(.custom(Appearance.shared.fontName, size: size.rawValue))
    }
}
