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

        public init(activeColor: Color = .defaultPrimary) {
            self.activeColor = activeColor
        }
    }
}
