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
        
        public init(text: TextAttributes = TextAttributes(font: .sdkDefault(size: .body)),
                    title: TextAttributes = TextAttributes(font: .sdkDefault(size: .body)),
                    placeholder: TextAttributes = TextAttributes(font: .sdkDefault(size: .body)),
                    error: TextAttributes = TextAttributes(font: .sdkDefault(size: .caption))) {
            self.text = text
            self.title = title
            self.placeholder = placeholder
            self.error = error
        }
    }
}
