//
//  CustomFont.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI
import UIKit

public struct CustomFont {

    public var type: FontType
    public var size: CGFloat

    public init(type: FontType = .system,
                size: CGFloat) {
        self.type = type
        self.size = size
    }

    var font: Font {
        switch type {
        case .system: return Font.system(size: size)
        case .custom(let name): return Font.custom(name, size: size)
        }
    }

    /// A font that scales with Dynamic Type (accessibility font size settings).
    var scaledFont: Font {
        switch type {
        case .system:
            let baseFont = UIFont.systemFont(ofSize: size)
            let scaledUIFont = UIFontMetrics.default.scaledFont(for: baseFont)
            return Font(scaledUIFont)
        case .custom(let name):
            return Font.custom(name, size: size, relativeTo: .body)
        }
    }

    var fontDescriptor: UIFontDescriptor {
        return uiFont.fontDescriptor
    }

    public var fontName: String {
        switch type {
        case .system: return UIFont.systemFont(ofSize: size).familyName
        case .custom(let name): return name
        }
    }

    var uiFont: UIFont {
        switch type {
        case .system:
            return UIFont.systemFont(ofSize: size)
        case .custom(let name):
            return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }

    public enum FontType {
        case system
        case custom(name: String)
    }
}
