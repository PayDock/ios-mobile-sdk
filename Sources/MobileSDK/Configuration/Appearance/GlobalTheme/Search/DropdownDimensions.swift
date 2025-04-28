//
//  DropdownDimensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct DropdownDimensions {
        public let padding: Double
        public let listSpacing: Double
        
        public init(padding: Double = 4,
                    listSpacing: Double = 12) { // Will require component
            self.padding = padding
            self.listSpacing = listSpacing
        }
    }
}
