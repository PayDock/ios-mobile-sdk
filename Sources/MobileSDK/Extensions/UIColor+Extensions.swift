//
//  UIColor+Extensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import UIKit

extension UIColor {

    func hex() -> String {
        let resolvedColor = resolvedColor(with: .current)
        if resolvedColor == .clear { return "transparent" }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)

        let color = String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        return color
    }
}
