//
//  CGFloat+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.09.2023..
//

import Foundation
import UIKit

extension CGFloat {
    
    static var buttonCornerRadius: CGFloat { Appearance.shared.dimensions.buttonCornerRadius }
    static var textFieldCornerRadius: CGFloat { Appearance.shared.dimensions.textFieldCornerRadius }
    static var borderWidth: CGFloat { Appearance.shared.dimensions.borderWidth }
    static var spacing: CGFloat { Appearance.shared.dimensions.spacing }
//
//    private static func getAccessibilityScaleFactor() -> CGFloat {
//        switch UIApplication.shared.preferredContentSizeCategory {
//        case .extraSmall: return 1.0
//        case .small: return 1.0
//        case .medium: return 1.0
//        case .large: return 1.2
//        case .extraLarge: return 1.4
//        case .extraExtraLarge: return 1.6
//        case .extraExtraExtraLarge: return 1.8
//        case .accessibilityMedium: return 2.0
//        case .accessibilityLarge: return 2.2
//        case .accessibilityExtraLarge: return 2.4
//        case .accessibilityExtraExtraLarge: return 2.6
//        case .accessibilityExtraExtraExtraLarge: return 2.8
//        default: return 1.0
//        }
//    }
}
