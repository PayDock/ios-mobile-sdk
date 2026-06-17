//
//  Theme.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct Theme:
    LoaderStylableAppearance,
    OverlayLoaderStylableAppearance,
    ToggleStylableAppearance,
    ActionButtonStylableAppearance,
    ExpandSectionButtonStylableAppearance,
    ToolbarButtonStylableAppearance,
    TextFieldStylableAppearance,
    DropdownStylableAppearance,
    TitleStylableAppearance,
    LinkTextStylableAppearance,
    ToggleTextStylableAppearance,
    SpacingStylableAppearance {

    public var horizontalSpacing: CGFloat
    public var verticalSpacing: CGFloat
    public var textFieldVerticalSpacing: CGFloat
    public var textField: TextFieldAppearance
    public var searchDropdown: SearchDropdownAppearance
    public var actionButton: ButtonAppearance
    public var expandSectionButton: ButtonAppearance
    public var toolbarButton: ButtonAppearance
    public var loader: LoaderAppearance
    public var overlayLoader: OverlayLoaderAppearance
    public var toggle: ToggleAppearance
    public var linkText: TextAppearance
    public var toggleText: TextAppearance
    public var title: TextAppearance

    public init(horizontalSpacing: CGFloat = 16,
                verticalSpacing: CGFloat = 16,
                textFieldVerticalSpacing: CGFloat = 8,
                textField: TextFieldAppearance = TextFieldAppearance(),
                searchDropdown: SearchDropdownAppearance = SearchDropdownAppearance(),
                actionButton: ButtonAppearance = ButtonAppearance(),
                expandSectionButton: Theme.ButtonAppearance = Theme.ButtonAppearance(
                    colors: .init(background: .defaultBackground, text: .defaultPrimary, border: .clear),
                    fonts: .init(title: .init(isUnderlined: true, underlineColor: .defaultPrimary))),
                toolbarButton: ButtonAppearance = ButtonAppearance(colors: .init(
                    background: .clear,
                    text: .defaultPrimary,
                    border: .clear)),
                loader: LoaderAppearance = LoaderAppearance(),
                overlayLoader: OverlayLoaderAppearance = OverlayLoaderAppearance(),
                toggle: ToggleAppearance = ToggleAppearance(),
                linkText: Theme.TextAppearance = Theme.TextAppearance(text:
                        .init(font: .init(size: 14), textColor: .defaultPrimary, isUnderlined: true, underlineColor: .defaultPrimary)),
                toggleText: TextAppearance = TextAppearance(text: .init(textColor: .defaultText)),
                description: TextAppearance = TextAppearance(),
                title: TextAppearance = TextAppearance(text: TextAttributes(font: .init(size: 16.0)))) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.textFieldVerticalSpacing = textFieldVerticalSpacing
        self.textField = textField
        self.searchDropdown = searchDropdown
        self.actionButton = actionButton
        self.expandSectionButton = expandSectionButton
        self.toolbarButton = toolbarButton
        self.loader = loader
        self.overlayLoader = overlayLoader
        self.toggle = toggle
        self.linkText = linkText
        self.toggleText = toggleText
        self.title = title
    }
}
