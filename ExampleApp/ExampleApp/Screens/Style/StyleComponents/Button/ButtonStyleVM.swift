//
//  ButtonStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class ButtonStyleVM<T>: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    private let buttonKeyPath: WritableKeyPath<T, Theme.ButtonAppearance>
    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    // MARK: - Variables
    
    private var appearance: T?
    @Published var showResetConfirmation = false
    
    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var imageColor: Color = .clear { didSet { updateAppearance() }}
    @Published var borderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var cornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var fontName: String = "" { didSet { updateAppearance() }}
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         buttonKeyPath: WritableKeyPath<T, Theme.ButtonAppearance>) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.buttonKeyPath = buttonKeyPath
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: T.self)
        syncUIToAppearance()
    }
    
    private func syncUIToAppearance() {
        let buttonAppearance = appearance?[keyPath: buttonKeyPath]
        self.backgroundColor = buttonAppearance?.colors.background ?? .clear
        self.textColor = buttonAppearance?.colors.text ?? .clear
        self.imageColor = buttonAppearance?.colors.text ?? .clear
        self.borderColor = buttonAppearance?.colors.border ?? .clear
        self.cornerRadius = buttonAppearance?.dimensions.cornerRadius ?? 0
        self.borderWidth = buttonAppearance?.dimensions.borderWidth ?? 0
        self.fontName = buttonAppearance?.fonts.title.customFont.name ?? ""
    }
    
    private func updateAppearance() {
        guard var appearance = appearance else { return }
        
        appearance[keyPath: buttonKeyPath].colors.background = backgroundColor
        appearance[keyPath: buttonKeyPath].colors.text = textColor
        appearance[keyPath: buttonKeyPath].colors.image = imageColor
        appearance[keyPath: buttonKeyPath].colors.border = borderColor
        appearance[keyPath: buttonKeyPath].dimensions.cornerRadius = cornerRadius
        appearance[keyPath: buttonKeyPath].dimensions.borderWidth = borderWidth
        appearance[keyPath: buttonKeyPath].fonts.title.customFont.name = fontName
        
        self.appearance = appearance
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
    
    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: T.self)

        syncUIToAppearance()
    }
}
