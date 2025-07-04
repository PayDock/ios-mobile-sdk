//
//  DropdownColors.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct DropdownColors {
        public var backgroundColor: Color
        
        public init(backgroundColor: Color = Color(red: 0.91, green: 0.80, blue: 0.96)) {
            self.backgroundColor = backgroundColor
        }
    }
}
