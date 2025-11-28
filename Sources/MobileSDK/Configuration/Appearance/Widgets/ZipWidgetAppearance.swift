//
//  ZipWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct ZipWidgetAppearance {

    /// The button style following Zip's brand guidelines
    /// Default: .colorOnBlack (colored icon on black background)
    /// Options:
    /// - whiteOnBlack: White icon on filled black background (recommended)
    /// - blackOnWhite: Black icon on white background with black border
    public var buttonStyle: ZipButtonStyle

    /// The corner radius of the button
    /// Default: 8.0 (per Zip brand guidelines)
    public var cornerRadius: CGFloat

    /// The loader/spinner appearance
    public var loader: Theme.ButtonLoader

    public init(buttonStyle: ZipButtonStyle = .whiteOnBlack,
                cornerRadius: CGFloat = 8.0,
                loader: Theme.ButtonLoader? = nil) {
        self.buttonStyle = buttonStyle
        self.cornerRadius = cornerRadius

        // Adapt loader color to button style
        if let loader = loader {
            self.loader = loader
        } else {
            // White spinner for dark backgrounds, black for white background
            let spinnerColor: Color = buttonStyle == .whiteOnBlack ? Color(hex: ("#FFFFFA")) : Color(hex: ("#1A0826"))
            self.loader = Theme.ButtonLoader(spinnerColor: spinnerColor)
        }
    }
}
