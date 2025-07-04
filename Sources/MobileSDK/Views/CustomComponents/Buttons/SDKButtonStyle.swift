//
//  ButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import Foundation
import SwiftUI

enum SDKButtonStyle {
    
    case fill(FillButtonStyle)
    case outline(OutlineButtonStyle)
    case image(ImageButtonStyle)
    // TODO: - Remove above once all widget themes are updated
    case custom(CustomButtonStyle)
    
    var isDisabled: Bool {
        switch self {
        case .fill(let style):
            return style.isDisabled
        case .outline(let style):
            return style.isDisabled
        case .image(let style):
            return style.isDisabled
        case .custom(let style):
            return style.isDisabled
        }
    }
    
    var textColour: Color {
        switch self {
        case .fill(let style):
            return style.appearance.colors.text
        case .outline(let style):
            return style.appearance.colors.text
        case .image:
            return .clear
        case .custom(let style):
            return style.appearance.colors.text
        }
    }
    
    var loaderColor: Color {
        switch self {
        case .fill(let style):
            return style.appearance.loader.spinnerColor
        case .outline(let style):
            return style.appearance.loader.spinnerColor
        case .image(let style):
            return style.appearance.spinnerColor
        case .custom(let style):
            return style.appearance.loader.spinnerColor
        }
    }
    
    var imageColor: Color {
        switch self {
        case .fill(let style):
            return style.appearance.colors.image
        case .outline(let style):
            return style.appearance.colors.image
        case .image:
            return .clear // It's a background button only - no image contained
        case .custom(let style):
            return style.appearance.colors.image
        }
    }
}
