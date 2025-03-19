//
//  StyleVM.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.07.2023..
//

import Foundation
import SwiftUI
import MobileSDK

class StyleVM: ObservableObject {
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let mobileSDK: MobileSDK
    
    // MARK: - Properties
    
    @Published var primaryColorHex = "6750A4" { didSet { primaryColor = Color(hex: primaryColorHex) }}
    @Published var onPrimaryColorHex = "FFFFFF" { didSet { onPrimaryColor = Color(hex: onPrimaryColorHex) }}
    @Published var textColorHex = "000000" { didSet { textColor = Color(hex: textColorHex) }}
    @Published var successColorHex = "1ABA1A" { didSet { successColor = Color(hex: successColorHex) }}
    @Published var errorColorHex = "B3261E" { didSet { errorColor = Color(hex: errorColorHex) }}
    @Published var backgroundColorHex = "FFFFFF" { didSet { backgroundColor = Color(hex: backgroundColorHex) }}
    @Published var borderColorHex = "8C8C8C" { didSet { borderColor = Color(hex: borderColorHex) }}
    @Published var placeholderColorHex = "8C8C8C" { didSet { placeholderColor = Color(hex: placeholderColorHex) }}
    
    lazy var primaryColor = Color(red: 0.4, green: 0.31, blue: 0.64) {
        didSet {
            guard primaryColor != oldValue else { return }
            primaryColorHex = primaryColor.toHex() ?? ""
        }
    }
    lazy var onPrimaryColor = Color.white  {
        didSet {
            guard onPrimaryColor != oldValue else { return }
            onPrimaryColorHex = onPrimaryColor.toHex() ?? ""
        }
    }
    lazy var textColor = Color.black {
        didSet {
            guard textColor != oldValue else { return }
            textColorHex = textColor.toHex() ?? ""
        }
    }
    lazy var successColor = Color(red: 0.1, green: 0.73, blue: 0.1) {
        didSet {
            guard successColor != oldValue else { return }
            successColorHex = successColor.toHex() ?? ""
        }
    }
    lazy var errorColor: Color = Color(red: 0.7, green: 0.15, blue: 0.12) {
        didSet {
            guard errorColor != oldValue else { return }
            errorColorHex = errorColor.toHex() ?? ""
        }
    }
    lazy var backgroundColor = Color.white {
        didSet {
            guard backgroundColor != oldValue else { return }
            backgroundColorHex = backgroundColor.toHex() ?? ""
        }
    }
    lazy var borderColor = Color(red: 0.55, green: 0.55, blue: 0.55) {
        didSet {
            guard borderColor != oldValue else { return }
            borderColorHex = borderColor.toHex() ?? ""
        }
    }
    lazy var placeholderColor = Color(red: 0.55, green: 0.55, blue: 0.55) {
        didSet {
            guard placeholderColor != oldValue else { return }
            placeholderColorHex = placeholderColor.toHex() ?? ""
        }
    }

    @Published var fontName = "FFF-AcidGrotesk-Normal"

    @Published var buttonCornerRadius = "4"
    @Published var textFieldCornerRadius = "4"
    @Published var borderWidth = "1"
    @Published var spacing = "16"

    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    var savedLightThemeColors = Colors(
        primary: Color(red: 0.4, green: 0.31, blue: 0.64),
        onPrimary: .white,
        text: .black,
        success: Color(red: 0.1, green: 0.73, blue: 0.1),
        error: Color(red: 0.7, green: 0.15, blue: 0.12),
        background: .white,
        border: Color(red: 0.55, green: 0.55, blue: 0.55),
        placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

    var savedDarkThemeColors = Colors(
        primary: Color(red: 0.4, green: 0.31, blue: 0.64),
        onPrimary: .white,
        text: .white,
        success: Color(red: 0.1, green: 0.73, blue: 0.1),
        error: Color(red: 0.7, green: 0.15, blue: 0.12),
        background: .black,
        border: Color(red: 0.55, green: 0.55, blue: 0.55),
        placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

    var isDarkModeEnabled: Bool { UITraitCollection.current.userInterfaceStyle == .dark }

    // MARK: - Initialisation

    init(mobileSDK: MobileSDK = MobileSDK.shared) {
        self.mobileSDK = mobileSDK
    }

    private func initialiseMobileSDK() {
        let colors = Colors(
            primary: primaryColor,
            onPrimary: onPrimaryColor,
            text: textColor,
            success: successColor,
            error: errorColor,
            background: backgroundColor,
            border: borderColor,
            placeholder: placeholderColor)

        if isDarkModeEnabled {
            savedDarkThemeColors = colors
        } else {
            savedLightThemeColors = colors
        }

        let dimensions = Dimensions(
            buttonCornerRadius: Double(buttonCornerRadius) ?? 4,
            textFieldCornerRadius: Double(textFieldCornerRadius) ?? 4,
            borderWidth: Double(borderWidth) ?? 1,
            spacing: Double(spacing) ?? 16)

        let theme = {
            if isDarkModeEnabled {
                return Theme(darkThemeColors: colors, dimensions: dimensions, fontName: self.fontName)
            } else {
                return Theme(lighThemeColorst: colors, dimensions: dimensions, fontName: self.fontName)
            }
        }()

        let config = {
            switch ProjectEnvironment.shared.environment {
            case .production: return MobileSDKConfig(environment: .production, theme: theme)
            case .sandbox: return MobileSDKConfig(environment: .sandbox, theme: theme)
            case .staging: return MobileSDKConfig(environment: .staging, theme: theme)
            }
        }()

        mobileSDK.configureMobileSDK(config: config)
    }

    func saveStyle() {
        initialiseMobileSDK()
    }

    func colorSchemeChangedTo(_ colorScheme: ColorScheme) {
        switch colorScheme {
        case .light:
            primaryColor = savedLightThemeColors.primary
            onPrimaryColor = savedLightThemeColors.onPrimary
            textColor = savedLightThemeColors.text
            successColor = savedLightThemeColors.success
            errorColor = savedLightThemeColors.error
            backgroundColor = savedLightThemeColors.background
            borderColor = savedLightThemeColors.border
            placeholderColor = savedLightThemeColors.placeholder

        case .dark:
            primaryColor = savedDarkThemeColors.primary
            onPrimaryColor = savedDarkThemeColors.onPrimary
            textColor = savedDarkThemeColors.text
            successColor = savedDarkThemeColors.success
            errorColor = savedDarkThemeColors.error
            backgroundColor = savedDarkThemeColors.background
            borderColor = savedDarkThemeColors.border
            placeholderColor = savedDarkThemeColors.placeholder

        @unknown default: break
        }
    }
}
