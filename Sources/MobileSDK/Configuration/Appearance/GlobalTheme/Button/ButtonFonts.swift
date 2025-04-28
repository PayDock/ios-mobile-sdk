//
//  ButtonFonts.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

extension Theme {
    
    public struct ButtonFonts {
        public let title: TextAttributes
        
        public init(title: TextAttributes = TextAttributes(font: .sdkDefault(size: .body))) {
            self.title = title
        }
    }
}
