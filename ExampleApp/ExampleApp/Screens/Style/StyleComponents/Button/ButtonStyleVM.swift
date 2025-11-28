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
    let allSystemIconNames = [
        "heart", "heart.fill", "star", "star.fill", "bookmark", "bookmark.fill",
        "house", "house.fill", "person", "person.fill", "envelope", "envelope.fill",
        "phone", "phone.fill", "message", "message.fill", "calendar", "calendar.circle.fill",
        "camera", "camera.fill", "photo", "photo.fill", "video", "video.fill",
        "music.note", "headphones", "speaker.wave.2", "speaker.wave.3",
        "gamecontroller", "gamecontroller.fill", "car", "car.fill", "airplane", "airplane.circle.fill",
        "mappin", "mappin.and.ellipse", "location", "location.fill",
        "bag", "bag.fill", "cart", "cart.fill", "creditcard", "creditcard.fill",
        "gift", "gift.fill", "alarm", "alarm.fill", "timer", "stopwatch",
        "plus", "minus", "multiply", "divide", "equal", "checkmark",
        "xmark", "exclamationmark", "questionmark", "info", "gear", "wrench",
        "lock", "lock.fill", "key", "key.fill", "shield", "shield.fill",
        "eye", "eye.fill", "eye.slash", "eye.slash.fill", "hand.thumbsup", "hand.thumbsdown",
        "paperplane", "paperplane.fill", "tray", "tray.fill", "folder", "folder.fill",
        "doc", "doc.fill", "pencil", "pencil.circle", "trash", "trash.fill"
    ]

    // MARK: - Variables

    private var appearance: T?
    @Published var showResetConfirmation = false

    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var imageColor: Color = .clear { didSet { updateAppearance() }}
    @Published var borderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var loaderColor: Color = .clear { didSet { updateAppearance() }}

    @Published var cornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var topPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var leadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var bottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var trailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}

    @Published var underlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var strikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var fontName: String = "" { didSet { updateAppearance() }}
    @Published var fontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    @Published var icon: Image? { didSet { updateAppearance() }}
    @Published var buttonText: String = "" { didSet { updateAppearance() }}

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
        self.loaderColor = buttonAppearance?.loader.spinnerColor ?? .clear

        self.cornerRadius = buttonAppearance?.dimensions.cornerRadius ?? 0
        self.borderWidth = buttonAppearance?.dimensions.borderWidth ?? 0
        self.topPadding = buttonAppearance?.dimensions.padding.top ?? 0
        self.leadingPadding = buttonAppearance?.dimensions.padding.leading ?? 0
        self.bottomPadding = buttonAppearance?.dimensions.padding.bottom ?? 0
        self.trailingPadding = buttonAppearance?.dimensions.padding.trailing ?? 0

        self.underlineColor = buttonAppearance?.fonts.title.underlineColor ?? .clear
        self.strikethroughColor = buttonAppearance?.fonts.title.strikethroughColor ?? .clear
        self.fontName = buttonAppearance?.fonts.title.customFont.name ?? ""
        self.fontSize = buttonAppearance?.fonts.title.customFont.size ?? 0

        self.icon = buttonAppearance?.icon
        self.buttonText = buttonAppearance?.text ?? ""
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance[keyPath: buttonKeyPath].colors.background = backgroundColor
        appearance[keyPath: buttonKeyPath].colors.text = textColor
        appearance[keyPath: buttonKeyPath].colors.image = imageColor
        appearance[keyPath: buttonKeyPath].colors.border = borderColor
        appearance[keyPath: buttonKeyPath].loader.spinnerColor = loaderColor

        appearance[keyPath: buttonKeyPath].dimensions.cornerRadius = cornerRadius
        appearance[keyPath: buttonKeyPath].dimensions.borderWidth = borderWidth
        appearance[keyPath: buttonKeyPath].dimensions.padding.top = topPadding
        appearance[keyPath: buttonKeyPath].dimensions.padding.leading = leadingPadding
        appearance[keyPath: buttonKeyPath].dimensions.padding.bottom = bottomPadding
        appearance[keyPath: buttonKeyPath].dimensions.padding.trailing = trailingPadding

        appearance[keyPath: buttonKeyPath].fonts.title.underlineColor = underlineColor
        appearance[keyPath: buttonKeyPath].fonts.title.strikethroughColor = strikethroughColor
        appearance[keyPath: buttonKeyPath].fonts.title.customFont.name = fontName
        appearance[keyPath: buttonKeyPath].fonts.title.customFont.size = fontSize

        appearance[keyPath: buttonKeyPath].icon = icon
        appearance[keyPath: buttonKeyPath].text = buttonText

        self.appearance = appearance
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: T.self)

        syncUIToAppearance()
    }
}
