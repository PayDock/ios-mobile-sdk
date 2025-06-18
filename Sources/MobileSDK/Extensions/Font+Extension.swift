//
//  Font+Extension.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public extension Font {
    
    static func sdkDefault(size: Fonts.Size) -> Font {
        return .custom(Appearance.shared.fontName, size: size.rawValue)
    }
}
