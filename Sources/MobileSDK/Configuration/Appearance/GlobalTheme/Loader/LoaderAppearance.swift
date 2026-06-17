//
//  LoaderAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct LoaderAppearance {
        public var color: Color
        public var overlayColor: Color

        public init(color: Color =  .defaultPrimary,
                    overlayColor: Color = .defaultLoaderOverlay) {
            self.color = color
            self.overlayColor = overlayColor
        }
    }
}
