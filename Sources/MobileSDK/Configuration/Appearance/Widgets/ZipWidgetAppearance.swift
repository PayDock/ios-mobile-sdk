//
//  ZipWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct ZipWidgetAppearance: ActionButtonLoaderStylableAppearance {

    /// The button style following Zip's brand guidelines
    /// Default: .colorOnBlack (colored icon on black background)
    /// Options:
    /// - whiteOnBlack: White icon on filled black background (recommended)
    /// - blackOnWhite: Black icon on white background with black border
    public var buttonStyle: ZipButtonStyle

    /// The loader/spinner appearance
    public var loader: Theme.ButtonLoader

    /// The corner radius of the button
    /// Brand guidelines mean this value is not editable
    public let cornerRadius: CGFloat

    public init(buttonStyle: ZipButtonStyle = .whiteOnBlack,
                loader: Theme.ButtonLoader? = nil) {
        self.buttonStyle = buttonStyle
        self.cornerRadius = 8.0

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
