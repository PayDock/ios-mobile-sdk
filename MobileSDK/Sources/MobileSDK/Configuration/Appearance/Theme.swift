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

    public init(lighThemeColorst: Colors,
                darkThemeColors: Colors,
                dimensions: Dimensions,
                fontName: String = "FFF-AcidGrotesk-Normal") {
        self.lightThemeColors = lighThemeColorst
        self.darkThemeColors = darkThemeColors
        self.dimensions = dimensions
        self.fontName = fontName
    }
}
