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
        public var padding: Padding
        public var listSpacing: Double

        public init(padding: Padding = Padding(),
                    listSpacing: Double = 8) {
            self.padding = padding
            self.listSpacing = listSpacing
        }
    }
}
