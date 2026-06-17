//
//  ButtonFonts.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

extension Theme {

    public struct ButtonFonts {
        public var title: TextAttributes

        public init(title: TextAttributes = TextAttributes(font: CustomFont(size: 16.0))) {
            self.title = title
        }
    }
}
