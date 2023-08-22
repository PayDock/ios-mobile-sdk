//
//  Fonts.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

struct Fonts {

    enum AcidGrotesk: String {
        case light = "FFF-AcidGrotesk-Light"
        case medium = "FFF-AcidGrotesk-Medium"
        case normal = "FFF-AcidGrotesk-Normal"
        case ultraLight = "FFF-AcidGrotesk-UltraLight"

        enum Size: CGFloat {
            case title = 36
            case title2 = 30
            case title3 = 21
            case title4 = 48
            case title5 = 60

            case headline = 18
            case headline2 = 17

            case body = 16
            case body2 = 15
            case body3 = 14

            case footnote = 13
            case caption = 12
            case caption2 = 10
        }
    }

}
