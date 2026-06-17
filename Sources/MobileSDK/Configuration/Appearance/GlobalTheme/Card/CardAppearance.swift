//
//  CardAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct CardAppearance {
        public var size: CGSize?
        public var cornerRadius: CGFloat
        public var color: Color
        public var padding: UIEdgeInsets

        public init(size: CGSize? = nil, // Set to nil for dynamic sizing
                    cornerRadius: CGFloat = 20,
                    color: Color = Color.defaultLoaderOverlay,
                    padding: UIEdgeInsets = UIEdgeInsets()) {
            self.size = size
            self.cornerRadius = cornerRadius
            self.color = color
            self.padding = padding
        }
    }
}
