//
//  TextTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct TextAppearance {
        public let text: TextAttributes
        
        public init(text: TextAttributes = TextAttributes(font: CustomFont(size: 14.0))) {
            self.text = text
        }
    }
}
