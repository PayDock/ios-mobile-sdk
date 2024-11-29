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

    @Published var primaryColorHex = "6750A4"
    @Published var onPrimaryColorHex = "FFFFFF"
    @Published var textColorHex = "000000"
    @Published var successColorHex = "1ABA1A"
    @Published var errorColorHex = "B3261E"
    @Published var backgroundColorHex = "FFFFFF"
    @Published var borderColorHex = "8C8C8C"
    @Published var placeholderColorHex = "8C8C8C"

    @Published var fontName = "FFF-AcidGrotesk-Normal"

    @Published var buttonCornerRadius = "4"
    @Published var textFieldCornerRadius = "4"
    @Published var padding = "16"
    @Published var borderWidth = "1"

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
        primary: .purple,
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
            primary: Color(hex: "#\(primaryColorHex)"),
            onPrimary: Color(hex: "#\(onPrimaryColorHex)"),
            text: Color(hex: "#\(textColorHex)"),
            success: Color(hex: "#\(successColorHex)"),
            error: Color(hex: "#\(errorColorHex)"),
            background: Color(hex: "#\(backgroundColorHex)"),
            border: Color(hex: "#\(borderColorHex)"),
            placeholder: Color(hex: "#\(placeholderColorHex)"))

        if isDarkModeEnabled {
            savedDarkThemeColors = colors
        } else {
            savedLightThemeColors = colors
        }

        let dimensions = Dimensions(
            buttonCornerRadius: Double(buttonCornerRadius) ?? 4,
            textFieldCornerRadius: Double(textFieldCornerRadius) ?? 4,
            borderWidth: Double(borderWidth) ?? 1,
            spacing: Double(padding) ?? 16)

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
            primaryColorHex = savedLightThemeColors.primary.toHex() ?? "6750A4"
            onPrimaryColorHex = savedLightThemeColors.onPrimary.toHex() ?? "FFFFFF"
            textColorHex = savedLightThemeColors.text.toHex() ?? "000000"
            successColorHex = savedLightThemeColors.success.toHex() ?? "1ABA1A"
            errorColorHex = savedLightThemeColors.error.toHex() ?? "B3261E"
            backgroundColorHex = savedLightThemeColors.background.toHex() ?? "FFFFFF"
            borderColorHex = savedLightThemeColors.border.toHex() ?? "8C8C8C"
            placeholderColorHex = savedLightThemeColors.placeholder.toHex() ?? "8C8C8C"

        case .dark:
            primaryColorHex = savedDarkThemeColors.primary.toHex() ?? "6750A4"
            onPrimaryColorHex = savedDarkThemeColors.onPrimary.toHex() ?? "FFFFFF"
            textColorHex = savedDarkThemeColors.text.toHex() ?? "000000"
            successColorHex = savedDarkThemeColors.success.toHex() ?? "1ABA1A"
            errorColorHex = savedDarkThemeColors.error.toHex() ?? "B3261E"
            backgroundColorHex = savedDarkThemeColors.background.toHex() ?? "FFFFFF"
            borderColorHex = savedDarkThemeColors.border.toHex() ?? "8C8C8C"
            placeholderColorHex = savedDarkThemeColors.placeholder.toHex() ?? "8C8C8C"

        @unknown default: break
        }
    }
}
