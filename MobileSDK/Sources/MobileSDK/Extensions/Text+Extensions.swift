//
//  Text+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

extension Text {

    func customFont(_ size: Fonts.Size) -> Text {
        font(.custom(Appearance.shared.fontName, size: size.rawValue))
    }
}
