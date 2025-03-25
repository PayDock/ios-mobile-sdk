//
//  Theme.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 31.08.2023..
//

import Foundation
import SwiftUI

public struct Theme {

    private(set) var colors: Colors
    private(set) var dimensions: Dimensions
    private(set) var fontName: String
    
    public init(
        colors: Colors = Colors(
            primary: .defaultPrimary,
            onPrimary: .defaultOnPrimary,
            text: .defaultText,
            success: .defaultSuccess,
            error: .defaultError,
            background: .defaultBackground,
            border: .defaultBorder,
            placeholder: .defaultPlaceholder),
        dimensions: Dimensions = Dimensions(buttonCornerRadius: 4, textFieldCornerRadius: 4, borderWidth: 1),
        fontName: String = "FFF-AcidGrotesk-Normal") {
            self.colors = colors
            self.dimensions = dimensions
            self.fontName = fontName
        }
}
