//
//  Colors.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.09.2023..
//

import SwiftUI

public struct Colors {

    public let primary: Color
    public let onPrimary: Color
    public let text: Color
    public let success: Color
    public let error: Color
    public let background: Color
    public let border: Color
    public let placeholder: Color

    public init(primary: Color,
                onPrimary: Color,
                text: Color,
                success: Color,
                error: Color,
                background: Color,
                border: Color,
                placeholder: Color) {
        self.primary = primary
        self.onPrimary = onPrimary
        self.text = text
        self.success = success
        self.error = error
        self.background = background
        self.border = border
        self.placeholder = placeholder
    }

}
