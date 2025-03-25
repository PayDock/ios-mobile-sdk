//
//  Color+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import Foundation
import SwiftUI

public extension Color {
    static var defaultPrimary: Color { Color(.primary) }
    static var defaultOnPrimary: Color { Color(.onPrimary) }
    static var defaultText: Color { Color(.text) }
    static var defaultSuccess: Color { Color(.success) }
    static var defaultError: Color { Color(.error) }
    static var defaultBackground: Color { Color(.background) }
    static var defaultBorder: Color { Color(.border) }
    static var defaultPlaceholder: Color { Color(.placeholder) }
    
    static var primaryColor: Color { Appearance.shared.colors.primary }
    static var onPrimaryColor: Color { Appearance.shared.colors.onPrimary }
    static var textColor: Color { Appearance.shared.colors.text }
    static var successColor: Color { Appearance.shared.colors.success }
    static var errorColor: Color { Appearance.shared.colors.error }
    static var backgroundColor: Color { Appearance.shared.colors.background }
    static var borderColor: Color { Appearance.shared.colors.border }
    static var placeholderColor: Color { Appearance.shared.colors.placeholder }
}
