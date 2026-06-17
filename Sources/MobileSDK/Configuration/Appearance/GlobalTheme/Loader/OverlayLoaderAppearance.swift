//
//  OverlayLoaderAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct OverlayLoaderAppearance {
        public var backgroundColor: Color
        public var showCard: Bool
        public var cardAppearance: CardAppearance
        public var loaderType: OverlayLoaderType
        public var loaderAppearance: LoaderAppearance
        public var loaderSize: CGSize
        public var loaderSpacing: CGFloat
        public var loaderText: String
        public var loaderTextAppearance: TextAppearance
        public var accessibilityLabel: String?
        public var accessibilityHint: String?
        public var accessibilityIdentifier: String?

        public init(backgroundColor: Color = .defaultLoaderOverlay,
                    showCard: Bool = true,
                    cardAppearance: CardAppearance = CardAppearance(
                        cornerRadius: 16,
                        color: .defaultBackground,
                        padding: UIEdgeInsets(top: 24, left: 32, bottom: 24, right: 32)),
                    loaderType: OverlayLoaderType = .swiftUIStyle,
                    loaderAppearance: LoaderAppearance = LoaderAppearance(),
                    loaderSize: CGSize = .init(width: 48, height: 48),
                    loaderSpacing: CGFloat = 16,
                    loaderText: String = "Loading...",
                    loaderTextAppearance: TextAppearance = TextAppearance(
                        text: TextAttributes(
                            font: CustomFont(type: .system, size: 16),
                            textColor: .defaultText,
                            isUnderlined: false,
                            isStrikethrough: false),
                        padding: Padding(top: 4)),
                    accessibilityLabel: String? = nil,
                    accessibilityHint: String? = nil,
                    accessibilityIdentifier: String? = nil) {
            self.backgroundColor = backgroundColor
            self.showCard = showCard
            self.cardAppearance = cardAppearance
            self.loaderType = loaderType
            self.loaderAppearance = loaderAppearance
            self.loaderSize = loaderSize
            self.loaderSpacing = loaderSpacing
            self.loaderText = loaderText
            self.loaderTextAppearance = loaderTextAppearance
            self.accessibilityLabel = accessibilityLabel
            self.accessibilityHint = accessibilityHint
            self.accessibilityIdentifier = accessibilityIdentifier
        }
    }
}
