//
//  OverlayLoaderStyleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

class OverlayLoaderStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    let allFontNames = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    let allLoaderTypes: [OverlayLoaderType] = [.swiftUIStyle, .uiKitActivityIndicator]

    // MARK: - Variables

    private var appearance: OverlayLoaderStylableAppearance?

    @Published var showResetConfirmation = false

    // Overlay
    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var showCard: Bool = true { didSet { updateAppearance() }}
    @Published var loaderType: OverlayLoaderType = .swiftUIStyle { didSet { updateAppearance() }}
    @Published var loaderSpacing: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var loaderText: String = "" { didSet { updateAppearance() }}
    @Published var loaderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var loaderHeight: CGFloat = 0.0 { didSet { updateAppearance() }}

    // Loader
    @Published var loaderColor: Color = .clear { didSet { updateAppearance() }}

    // Card
    @Published var useDynamicCardSize: Bool = true { didSet { updateAppearance() }}
    @Published var cardWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardHeight: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardCornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardBackgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var cardTopPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardLeftPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardBottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var cardRightPadding: CGFloat = 0.0 { didSet { updateAppearance() }}

    // Text
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textFontName: String = "" { didSet { updateAppearance() }}
    @Published var textFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textIsUnderlined: Bool = false { didSet { updateAppearance() }}
    @Published var textUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textIsStrikethrough: Bool = false { didSet { updateAppearance() }}
    @Published var textStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textIsItalic: Bool = false { didSet { updateAppearance() }}
    @Published var textTopPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textLeadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textBottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textTrailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: OverlayLoaderStylableAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        guard let overlay = appearance?.overlayLoader else { return }

        self.backgroundColor = overlay.backgroundColor
        self.showCard = overlay.showCard
        self.loaderType = overlay.loaderType
        self.loaderSpacing = overlay.loaderSpacing
        self.loaderText = overlay.loaderText
        self.loaderWidth = overlay.loaderSize.width
        self.loaderHeight = overlay.loaderSize.height

        self.loaderColor = overlay.loaderAppearance.color

        self.useDynamicCardSize = overlay.cardAppearance.size == nil
        self.cardWidth = overlay.cardAppearance.size?.width ?? 0
        self.cardHeight = overlay.cardAppearance.size?.height ?? 0
        self.cardCornerRadius = overlay.cardAppearance.cornerRadius
        self.cardBackgroundColor = overlay.cardAppearance.color
        self.cardTopPadding = overlay.cardAppearance.padding.top
        self.cardLeftPadding = overlay.cardAppearance.padding.left
        self.cardBottomPadding = overlay.cardAppearance.padding.bottom
        self.cardRightPadding = overlay.cardAppearance.padding.right

        self.textColor = overlay.loaderTextAppearance.text.textColor
        self.textFontName = overlay.loaderTextAppearance.text.customFont.fontName
        self.textFontSize = overlay.loaderTextAppearance.text.customFont.size
        self.textIsUnderlined = overlay.loaderTextAppearance.text.isUnderlined
        self.textUnderlineColor = overlay.loaderTextAppearance.text.underlineColor
        self.textIsStrikethrough = overlay.loaderTextAppearance.text.isStrikethrough
        self.textStrikethroughColor = overlay.loaderTextAppearance.text.strikethroughColor
        self.textIsItalic = overlay.loaderTextAppearance.text.isItalic
        self.textTopPadding = overlay.loaderTextAppearance.padding.top
        self.textLeadingPadding = overlay.loaderTextAppearance.padding.leading
        self.textBottomPadding = overlay.loaderTextAppearance.padding.bottom
        self.textTrailingPadding = overlay.loaderTextAppearance.padding.trailing
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.overlayLoader.backgroundColor = backgroundColor
        appearance.overlayLoader.showCard = showCard
        appearance.overlayLoader.loaderType = loaderType
        appearance.overlayLoader.loaderSpacing = loaderSpacing
        appearance.overlayLoader.loaderText = loaderText
        appearance.overlayLoader.loaderSize = CGSize(width: loaderWidth, height: loaderHeight)

        appearance.overlayLoader.loaderAppearance.color = loaderColor

        appearance.overlayLoader.cardAppearance.size = useDynamicCardSize
            ? nil
            : CGSize(width: cardWidth, height: cardHeight)
        appearance.overlayLoader.cardAppearance.cornerRadius = cardCornerRadius
        appearance.overlayLoader.cardAppearance.color = cardBackgroundColor
        appearance.overlayLoader.cardAppearance.padding = UIEdgeInsets(
            top: cardTopPadding,
            left: cardLeftPadding,
            bottom: cardBottomPadding,
            right: cardRightPadding)

        appearance.overlayLoader.loaderTextAppearance.text.textColor = textColor
        appearance.overlayLoader.loaderTextAppearance.text.customFont.type = .custom(name: textFontName)
        appearance.overlayLoader.loaderTextAppearance.text.customFont.size = textFontSize
        appearance.overlayLoader.loaderTextAppearance.text.isUnderlined = textIsUnderlined
        appearance.overlayLoader.loaderTextAppearance.text.underlineColor = textUnderlineColor
        appearance.overlayLoader.loaderTextAppearance.text.isStrikethrough = textIsStrikethrough
        appearance.overlayLoader.loaderTextAppearance.text.strikethroughColor = textStrikethroughColor
        appearance.overlayLoader.loaderTextAppearance.text.isItalic = textIsItalic
        appearance.overlayLoader.loaderTextAppearance.padding.top = textTopPadding
        appearance.overlayLoader.loaderTextAppearance.padding.leading = textLeadingPadding
        appearance.overlayLoader.loaderTextAppearance.padding.bottom = textBottomPadding
        appearance.overlayLoader.loaderTextAppearance.padding.trailing = textTrailingPadding

        self.appearance = appearance
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: OverlayLoaderStylableAppearance.self)
        syncUIToAppearance()
    }
}
