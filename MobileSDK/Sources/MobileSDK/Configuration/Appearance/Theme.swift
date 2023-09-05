//
//  Theme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 31.08.2023..
//

import Foundation
import SwiftUI

public struct Theme {

    private(set) var lightThemeColors: Colors
    private(set) var darkThemeColors: Colors
    private(set) var dimensions: Dimensions
    private(set) var font: Font

    public init(lighThemeColorst: Colors,
                darkThemeColors: Colors,
                dimensions: Dimensions,
                font: Font = .body) {
        self.lightThemeColors = lighThemeColorst
        self.darkThemeColors = darkThemeColors
        self.dimensions = dimensions
        self.font = font
    }
}

//{
//    "colours": {
//        "light": {
//            "primary": "#6750A4",
//            "onPrimary": "#FFFFFF",
//            "text": "#1D1B20",
//            "success": "#1ABA1A",
//            "error": "#B3261E",
//            "background": "#FFFFFF",
//            "border": "#79747E",
//            "placeholder": "#8C8C8C"
//        },
//        "dark": {
//            "primary": "#FFFFFF",
//            "onPrimary": "#191919",
//            "text": "#FFFFFF",
//            "success": "#69B134",
//            "error": "#EB66CA",
//            "background": "#0B0C0C",
//            "border": "#707974",
//            "placeholder": "#B1B4B6"
//        }
//    },
//    "dimensions": {
//        "cornerRadius": 4,
//        "shadow": 0,
//        "borderWidth": 1,
//        "spacing": 16
//    },
//    "font": {
//        "familyName": "Acid-Grotesk"
//    }
//}
