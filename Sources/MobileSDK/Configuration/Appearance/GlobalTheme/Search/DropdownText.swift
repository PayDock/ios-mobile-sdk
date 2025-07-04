//
//  DropdownText.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct DropdownText {
        public var listText: TextAppearance
        
        public init(listText: TextAppearance = TextAppearance()) {
            self.listText = listText
        }
    }
}
