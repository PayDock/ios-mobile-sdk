//
//  TextFieldDimensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct TextFieldDimensions {
        public let cornerRadius: CGFloat
        public let borderWidth: CGFloat
        public let activeBorderWidth: CGFloat
        public let padding: CGFloat // TODO: Not used currently by the component
        
        public init(cornerRadius: CGFloat = .defaultTextFieldCornerRadius,
                    borderWidth: CGFloat = .defaultBorderWidth,
                    activeBorderWidth: CGFloat = .defaultBorderWidth * 2,
                    padding: CGFloat = 4) { // TODO: Not used currently by the component
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.activeBorderWidth = activeBorderWidth
            self.padding = padding
        }
    }
}
