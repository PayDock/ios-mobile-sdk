//
//  ButtonDimensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

extension Theme {
    
    public struct ButtonDimensions {
        public let cornerRadius: CGFloat
        public let borderWidth: CGFloat
        public let padding: Padding
        
        public init(cornerRadius: CGFloat = .defaultButtonCornerRadius,
                    borderWidth: CGFloat = .defaultBorderWidth,
                    padding: Padding = Padding()) {
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.padding = padding
        }
    }
}
