//
//  Appearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.09.2023..
//

import Foundation
import SwiftUI

/// An object containing visual configuration for whole SDK.
struct Appearance {

    var lightThemeColors = Colors()

    var darkThemeColors = Colors()

    var dimensions = Dimensions()

    var fontName: String = "FFF-AcidGrotesk-Normal"
}

// MARK: - Appearance + shared

extension Appearance {
    static var shared: Appearance = .init()
}
