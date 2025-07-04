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
        public var text: TextAttributes
        public var padding: Padding
        
        public init(text: TextAttributes = TextAttributes(),
                    padding: Padding = Padding()) {
            self.text = text
            self.padding = padding
        }
    }
}
