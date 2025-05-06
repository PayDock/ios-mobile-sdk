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
        public let text: TextAttributes
        public let title: TextAttributes
        public let placeholder: TextAttributes
        public let error: TextAttributes
        
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
