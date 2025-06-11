//
//  CustomFont.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

public struct CustomFont {
    
    public var name: String
    public var size: CGFloat
    
    public init(name: String = "FFF-AcidGrotesk-Normal",
                size: CGFloat) {
        self.name = name
        self.size = size
    }
    
    var font: Font {
        Font.custom(name, size: size)
    }
}
