//
//  Text+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

extension Text {

    func customFont(_ size: Fonts.AcidGrotesk.Size, weight: Fonts.AcidGrotesk = .normal) -> Text {
        font(.custom(weight.rawValue, size: size.rawValue))
    }
}
