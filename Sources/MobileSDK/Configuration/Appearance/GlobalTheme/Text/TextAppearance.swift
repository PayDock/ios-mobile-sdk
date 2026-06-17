//
//  TextTheme.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct TextAppearance {
        public var text: TextAttributes
        public var padding: Padding

        public init(text: TextAttributes = TextAttributes(),
                    padding: Padding = Padding()) {
            self.text = text
            self.padding = padding
        }
    }
}
