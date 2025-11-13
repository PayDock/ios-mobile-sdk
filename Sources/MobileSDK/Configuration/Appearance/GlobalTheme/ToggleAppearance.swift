//
//  ToggleTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct ToggleAppearance {
        public var activeColor: Color
        public var inactiveColor: Color?
        public var toggleColor: Color?

        public init(activeColor: Color = .defaultPrimary,
                    inactiveColor: Color? = nil,
                    toggleColor: Color? = nil) {
            self.activeColor = activeColor
            self.inactiveColor = inactiveColor
            self.toggleColor = toggleColor
        }
    }
}
