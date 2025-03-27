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
    
    @Published var primaryColorHex = Color.defaultPrimary.toHex() { didSet { primaryColor = Color(hex: primaryColorHex) }}
    @Published var onPrimaryColorHex = Color.defaultOnPrimary.toHex() { didSet { onPrimaryColor = Color(hex: onPrimaryColorHex) }}
    @Published var textColorHex = Color.defaultText.toHex() { didSet { textColor = Color(hex: textColorHex) }}
    @Published var successColorHex = Color.defaultSuccess.toHex() { didSet { successColor = Color(hex: successColorHex) }}
    @Published var errorColorHex = Color.defaultError.toHex() { didSet { errorColor = Color(hex: errorColorHex) }}
    @Published var backgroundColorHex = Color.defaultBackground.toHex() { didSet { backgroundColor = Color(hex: backgroundColorHex) }}
    @Published var borderColorHex = Color.defaultBorder.toHex() { didSet { borderColor = Color(hex: borderColorHex) }}
    @Published var placeholderColorHex = Color.defaultPlaceholder.toHex() { didSet { placeholderColor = Color(hex: placeholderColorHex) }}
    
    lazy var primaryColor = Color.primaryColor {
        didSet {
            guard primaryColor != oldValue else { return }
            primaryColorHex = primaryColor.toHex()
        }
    }
    lazy var onPrimaryColor = Color.onPrimaryColor  {
        didSet {
            guard onPrimaryColor != oldValue else { return }
            onPrimaryColorHex = onPrimaryColor.toHex()
        }
    }
    lazy var textColor = Color.textColor {
        didSet {
            guard textColor != oldValue else { return }
            textColorHex = textColor.toHex()
        }
    }
    lazy var successColor = Color.successColor {
        didSet {
            guard successColor != oldValue else { return }
            successColorHex = successColor.toHex()
        }
    }
    lazy var errorColor = Color.errorColor {
        didSet {
            guard errorColor != oldValue else { return }
            errorColorHex = errorColor.toHex()
        }
    }
    lazy var backgroundColor = Color.backgroundColor {
        didSet {
            guard backgroundColor != oldValue else { return }
            backgroundColorHex = backgroundColor.toHex()
        }
    }
    lazy var borderColor = Color.borderColor {
        didSet {
            guard borderColor != oldValue else { return }
            borderColorHex = borderColor.toHex()
        }
    }
    lazy var placeholderColor = Color.placeholderColor {
        didSet {
            guard placeholderColor != oldValue else { return }
            placeholderColorHex = placeholderColor.toHex()
        }
    }

    @Published var fontName = "FFF-AcidGrotesk-Normal"

    @Published var buttonCornerRadius = "4"
    @Published var textFieldCornerRadius = "4"
    @Published var borderWidth = "1"
    @Published var spacing = "16"

    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    var savedLightThemeColors = Colors(
        primary: .defaultPrimary,
        onPrimary: .defaultOnPrimary,
        text: .defaultText,
        success: .defaultSuccess,
        error: .defaultError,
        background: .defaultBackground,
        border: .defaultBorder,
        placeholder: .defaultPlaceholder)

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

            savedLightThemeColors = colors

        let dimensions = Dimensions(
            buttonCornerRadius: Double(buttonCornerRadius) ?? 4,
            textFieldCornerRadius: Double(textFieldCornerRadius) ?? 4,
            borderWidth: Double(borderWidth) ?? 1,
            spacing: Double(spacing) ?? 16)

        let theme = {
            return Theme(colors: colors, dimensions: dimensions, fontName: self.fontName)
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
        primaryColor = .defaultPrimary
        onPrimaryColor = .defaultOnPrimary
        textColor = .defaultText
        successColor = .defaultSuccess
        errorColor = .defaultError
        backgroundColor = .defaultBackground
        borderColor = .defaultBorder
        placeholderColor = .defaultPlaceholder
    }
}
