//
//  LoaderTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct OverlayLoaderAppearance {
        public let color: Color
        public let overlayColor: Color
        
        public init(color: Color = .defaultPrimary,
                    overlayColor: Color = .defaultLoaderOverlay) {
            self.color = color
            self.overlayColor = overlayColor
        }
    }
}
