//
//  Theme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 31.08.2023..
//

import Foundation
import SwiftUI

public struct Theme {

    private let lightThemeColors: Colors
    private let darkThemeColors: Colors

    public init(lighThemeColorst: Colors,
                darkThemeColors: Colors) {
        self.lightThemeColors = lighThemeColorst
        self.darkThemeColors = darkThemeColors
    }

    public struct Colors {

        public let primary: Color
        public let onPrimary: Color
        public let text: Color
        public let success: Color
        public let error: Color
        public let background: Color
        public let border: Color
        public let placeholder: Color

        public init(primary: Color,
                    onPrimary: Color,
                    text: Color,
                    success: Color,
                    error: Color,
                    background: Color,
                    border: Color,
                    placeholder: Color) {
            self.primary = primary
            self.onPrimary = onPrimary
            self.text = text
            self.success = success
            self.error = error
            self.background = background
            self.border = border
            self.placeholder = placeholder
        }
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
