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

    public init(primary: Color = Color(red: 0.4, green: 0.31, blue: 0.64),
                onPrimary: Color = .white,
                text: Color = .black,
                success: Color = Color(red: 0.55, green: 0.55, blue: 0.55),
                error: Color = Color(red: 0.7, green: 0.15, blue: 0.12),
                background: Color = .white,
                border: Color = Color(red: 0.55, green: 0.55, blue: 0.55),
                placeholder: Color = Color(red: 0.55, green: 0.55, blue: 0.55)) {
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
