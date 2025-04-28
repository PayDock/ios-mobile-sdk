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
        public let backgroundColor: Color
        public let highlightedColor: Color
        
        public init(backgroundColor: Color = .defaultBackground,
                    highlightedColor: Color = .defaultBackground) { // TODO: - Not used currently in the component
            self.backgroundColor = backgroundColor
            self.highlightedColor = highlightedColor
        }
    }
}
