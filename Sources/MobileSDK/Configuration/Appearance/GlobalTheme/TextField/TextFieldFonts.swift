//
//  TextFieldFonts.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldFonts {
        public var text: TextAttributes
        public var title: TextAttributes
        public var placeholder: TextAttributes
        public var error: TextAttributes

        public init(text: TextAttributes = TextAttributes(font: CustomFont(size: 16)),
                    title: TextAttributes = TextAttributes(font: CustomFont(size: 16)),
                    placeholder: TextAttributes = TextAttributes(font: CustomFont(size: 16)),
                    error: TextAttributes = TextAttributes(font: CustomFont(size: 12))) {
            self.text = text
            self.title = title
            self.placeholder = placeholder
            self.error = error
        }
    }
}
