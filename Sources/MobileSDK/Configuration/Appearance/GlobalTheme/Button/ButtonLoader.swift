//
//  ButtonLoader.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

extension Theme {
    
    public struct ButtonLoader {
        public var spinnerColor: Color
        
        public init(spinnerColor: Color = .defaultOnPrimary) {
            self.spinnerColor = spinnerColor
        }
    }
}
