//
//  Color+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import Foundation

import SwiftUI

extension Color {

    init(light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color) {
        self.init(UIColor(light: UIColor(lightModeColor()), dark: UIColor(darkModeColor())))
    }

    public static var primaryColor: Self {
        Self(light: Appearance.shared.lightThemeColors.primary,
             dark: Appearance.shared.darkThemeColors.primary)
    }

    static var primaryLightColor: Self {
        Self(light: Appearance.shared.lightThemeColors.primary.opacity(0.3),
             dark: Appearance.shared.darkThemeColors.primary.opacity(0.3))
    }

    static var onPrimaryColor: Self {
        Self(light: Appearance.shared.lightThemeColors.onPrimary,
             dark: Appearance.shared.darkThemeColors.onPrimary)
    }

    static var textColor: Self {
        Self(light: Appearance.shared.lightThemeColors.text,
             dark: Appearance.shared.darkThemeColors.text)
    }

    static var successColor: Self {
        Self(light: Appearance.shared.lightThemeColors.success,
             dark: Appearance.shared.darkThemeColors.success)
    }

    static var errorColor: Self {
        Self(light: Appearance.shared.lightThemeColors.error,
             dark: Appearance.shared.darkThemeColors.error)
    }

    static var backgroundColor: Self {
        Self(light: Appearance.shared.lightThemeColors.background,
             dark: Appearance.shared.darkThemeColors.background)
    }

    static var borderColor: Self {
        Self(light: Appearance.shared.lightThemeColors.border,
             dark: Appearance.shared.darkThemeColors.border)
    }

    static var placeholderColor: Self {
        Self(light: Appearance.shared.lightThemeColors.placeholder,
             dark: Appearance.shared.darkThemeColors.placeholder)
    }

}

extension UIColor {
    convenience init(light lightModeColor: @escaping @autoclosure () -> UIColor,
                     dark darkModeColor: @escaping @autoclosure () -> UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light: return lightModeColor()
            case .dark: return darkModeColor()
            case .unspecified: return lightModeColor()
            @unknown default: return lightModeColor()
            }
        }
    }
}
