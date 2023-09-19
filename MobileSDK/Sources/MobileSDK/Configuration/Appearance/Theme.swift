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
    private(set) var fontName: String
    
    public init(
        lighThemeColorst: Colors =
        Colors(
            primary: Color(red: 0.4, green: 0.31, blue: 0.64),
            onPrimary: .white,
            text: .black,
            success: Color(red: 0.1, green: 0.73, blue: 0.1),
            error: Color(red: 0.7, green: 0.15, blue: 0.12),
            background: .white,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55)),

        darkThemeColors: Colors =
        Colors(
            primary: .purple,
            onPrimary: .white,
            text: .white,
            success: Color(red: 0.1, green: 0.73, blue: 0.1),
            error: Color(red: 0.7, green: 0.15, blue: 0.12),
            background: .black,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55)),

        dimensions: Dimensions = Dimensions(cornerRadius: 4, borderWidth: 1, spacing: 16),
        fontName: String = "FFF-AcidGrotesk-Normal") {
            self.lightThemeColors = lighThemeColorst
            self.darkThemeColors = darkThemeColors
            self.dimensions = dimensions
            self.fontName = fontName
        }
}
