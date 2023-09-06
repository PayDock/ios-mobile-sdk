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

    // MARK: - Dependencies

    private let mobileSDK: MobileSDK

    // MARK: - Properties

    @Published var primaryColor = "000000"
    @Published var onPrimaryColor = "000000"
    @Published var textColor = "FFFFFF"
    @Published var successColor = "FFFFFF"
    @Published var errorColor = "FFFFFF"
    @Published var backgroundColor = "FFFFFF"
    @Published var borderColor = "FFFFFF"
    @Published var placeholderColor = "FFFFFF"

    @Published var fontName = "San Francisco"

    @Published var cornerRadius = "0"
    @Published var padding = "0"

    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    // MARK: - Initialisation

    init(mobileSDK: MobileSDK = MobileSDK.shared) {
        self.mobileSDK = mobileSDK

        initialiseMobileSDK()
    }

    private func initialiseMobileSDK() {
        let lightThemeColors = Colors(
            primary: Color(red: 0.4, green: 0.31, blue: 0.64),
            onPrimary: .white,
            text: .black,
            success: Color(red: 0.55, green: 0.55, blue: 0.55),
            error: Color(red: 0.7, green: 0.15, blue: 0.12),
            background: .white,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let darkThemeColors = Colors(
            primary: .purple,
            onPrimary: .white,
            text: .white,
            success: Color(red: 0.55, green: 0.55, blue: 0.55),
            error: .red,
            background: .black,
            border: Color(red: 0.55, green: 0.55, blue: 0.55),
            placeholder: Color(red: 0.55, green: 0.55, blue: 0.55))

        let dimensions = Dimensions(cornerRadius: 4, borderWidth: 1, spacing: 16)

        let theme = Theme(
            lighThemeColorst: lightThemeColors,
            darkThemeColors: darkThemeColors,
            dimensions: dimensions)

        var config: MobileSDKConfig
        switch ProjectEnvironment.shared.environment {
        case .production: config = MobileSDKConfig(environment: .production, theme: theme)
        case .sandbox: config = MobileSDKConfig(environment: .sandbox, theme: theme)
        case .staging: config = MobileSDKConfig(environment: .staging, theme: theme)
        }

        mobileSDK.configureMobileSDK(config: config)
    }

    func saveStyle() {
        
    }
}
