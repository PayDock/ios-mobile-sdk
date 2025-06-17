//
//  TextStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 13.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class TextStyleVM<T>: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    private let textKeyPath: WritableKeyPath<T, Theme.TextAppearance>
    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    // MARK: - Variables
    
    private var appearance: T?
    
    // Colors
    @Published var textColor: Color { didSet { updateAppearance() }}
    @Published var underlineColor: Color { didSet { updateAppearance() }}
    @Published var strikethroughColor: Color { didSet { updateAppearance() }}
        
    // Dimensions
    @Published var topPadding: CGFloat { didSet { updateAppearance() }}
    @Published var leadingPadding: CGFloat { didSet { updateAppearance() }}
    @Published var bottomPadding: CGFloat { didSet { updateAppearance() }}
    @Published var trailingPadding: CGFloat { didSet { updateAppearance() }}
    
    // Fonts
    @Published var fontName: String { didSet { updateAppearance() }}
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         textKeyPath: WritableKeyPath<T, Theme.TextAppearance>) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.textKeyPath = textKeyPath
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: T.self)
        
        let textAppearance = appearance?[keyPath: textKeyPath]
        
        self.textColor = textAppearance?.text.textColor ?? .clear
        self.underlineColor = textAppearance?.text.underlineColor ?? .clear
        self.strikethroughColor = textAppearance?.text.strikethroughColor ?? .clear
        
        self.topPadding = textAppearance?.padding.top ?? 0
        self.leadingPadding = textAppearance?.padding.leading ?? 0
        self.bottomPadding = textAppearance?.padding.bottom ?? 0
        self.trailingPadding = textAppearance?.padding.trailing ?? 0
        
        self.fontName = textAppearance?.text.customFont.name ?? ""
    }
    
    private func updateAppearance() {
        guard var appearance = appearance else { return }
        
        appearance[keyPath: textKeyPath].text.textColor = textColor
        appearance[keyPath: textKeyPath].text.underlineColor = underlineColor
        appearance[keyPath: textKeyPath].text.strikethroughColor = strikethroughColor
        
        appearance[keyPath: textKeyPath].padding.top = topPadding
        appearance[keyPath: textKeyPath].padding.leading = leadingPadding
        appearance[keyPath: textKeyPath].padding.bottom = bottomPadding
        appearance[keyPath: textKeyPath].padding.trailing = trailingPadding
        
        appearance[keyPath: textKeyPath].text.customFont.name = fontName
        
        self.appearance = appearance
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
}
