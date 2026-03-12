//
//  ZipButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//

import Foundation
import SwiftUI

/// Zip button styles following Zip's official brand guidelines
/// https://www.zippartner.co/
public enum ZipButtonStyle {
    /// Colored icon on filled black background (recommended default)
    case whiteOnBlack

    /// Colored icon with black dot on white background with black border
    case blackOnWhite

    /// Get the background color for this style
    internal var backgroundColor: Color {
        switch self {
        case .whiteOnBlack:
            return Color(hex: ("#1A0826"))
        case .blackOnWhite:
            return Color(hex: ("#FFFFFA"))
        }
    }

    /// Get the border color for this style
    internal var borderColor: Color {
        switch self {
        case .whiteOnBlack:
            return .clear
        case .blackOnWhite:
            return .black
        }
    }

    /// Get the border width for this style
    internal var borderWidth: CGFloat {
        switch self {
        case .whiteOnBlack:
            return 0
        case .blackOnWhite:
            return 1
        }
    }

    /// Get the image asset name for this style
    internal var imageName: String {
        switch self {
        case .whiteOnBlack:
            return "zip-logo-white"
        case .blackOnWhite:
            return "zip-logo-colored"
        }
    }
}
