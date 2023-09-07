//
//  StyleVM.swift
//  ExampleApp
//
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

    @Published var cornerRadius = "4"
    @Published var padding = "16"
    @Published var borderWidth = "1"

    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    var savedLightThemeColors = Colors()
    var savedDarkThemeColors = Colors()

    // MARK: - Initialisation

    init(mobileSDK: MobileSDK = MobileSDK.shared) {
        self.mobileSDK = mobileSDK
    }

    private func initialiseMobileSDK() {
        let lightThemeColors = Colors(
            primary: Color(hex: "#\(primaryColorHex)"),
            onPrimary: Color(hex: "#\(onPrimaryColorHex)"),
            text: Color(hex: "#\(textColorHex)"),
            success: Color(hex: "#\(successColorHex)"),
            error: Color(hex: "#\(errorColorHex)"),
            background: Color(hex: "#\(backgroundColorHex)"),
            border: Color(hex: "#\(borderColorHex)"),
            placeholder: Color(hex: "#\(placeholderColorHex)"))

        let darkThemeColors = Colors(
            primary: Color(hex: "#\(primaryColorHex)"),
            onPrimary: Color(hex: "#\(onPrimaryColorHex)"),
            text: Color(hex: "#\(textColorHex)"),
            success: Color(hex: "#\(successColorHex)"),
            error: Color(hex: "#\(errorColorHex)"),
            background: Color(hex: "#\(backgroundColorHex)"),
            border: Color(hex: "#\(borderColorHex)"),
            placeholder: Color(hex: "#\(placeholderColorHex)"))

        let dimensions = Dimensions(cornerRadius: Double(cornerRadius) ?? 4, borderWidth: Double(borderWidth) ?? 1, spacing: Double(padding) ?? 16)

        let theme = Theme(
            lighThemeColorst: lightThemeColors,
            darkThemeColors: darkThemeColors,
            dimensions: dimensions,
            fontName: fontName)

        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production, theme: theme)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox, theme: theme)
        case .staging: config = MobileSDKConfig(environment: .staging, theme: theme)
        }

        mobileSDK.configureMobileSDK(config: config)
    }

    func saveStyle() {
        initialiseMobileSDK()
    }

    func colorSchemeChangedTo(_ colorScheme: ColorScheme) {
        switch colorScheme {
        case .light:

        case .dark:

        @unknown default: break
        }
    }
}
