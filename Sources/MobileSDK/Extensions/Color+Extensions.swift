//
//  Color+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import Foundation
import SwiftUI
import UIKit

public extension Color {
    static var defaultPrimary: Color { Color(.primary) }
    static var defaultOnPrimary: Color { Color(.onPrimary) }
    static var defaultText: Color { Color(.text) }
    static var defaultSuccess: Color { Color(.success) }
    static var defaultError: Color { Color(.error) }
    static var defaultBackground: Color { Color(.background) }
    static var defaultBorder: Color { Color(.border) }
    static var defaultPlaceholder: Color { Color(.placeholder) }
    static var defaultLoaderOverlay: Color { .black.opacity(0.3)}
}

extension Color {

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    func toHex() -> String {
        if self == .clear { return "transparent" }
        return UIColor(self).hex()
    }
}
