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
    
    var lightThemeColors = Colors(
        primary: Color(red: 0.4, green: 0.31, blue: 0.64),
        onPrimary: .white,
        text: .black,
        success: Color(red: 0.1, green: 0.73, blue: 0.1),
        error: Color(red: 0.7, green: 0.15, blue: 0.12),
        background: .white,
        border: Color(red: 0.55, green: 0.55, blue: 0.55),
        placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))
    
    var darkThemeColors = Colors(
        primary: Color(red: 0.4, green: 0.31, blue: 0.64),
        onPrimary: .white,
        text: .white,
        success: Color(red: 0.1, green: 0.73, blue: 0.1),
        error: Color(red: 0.7, green: 0.15, blue: 0.12),
        background: .black,
        border: Color(red: 0.55, green: 0.55, blue: 0.55),
        placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

    var dimensions = Dimensions()

    var fontName: String = ""
}

// MARK: - Appearance + shared

extension Appearance {
    static var shared: Appearance = .init()
}
