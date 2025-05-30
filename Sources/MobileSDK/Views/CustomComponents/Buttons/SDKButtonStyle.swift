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
    
    var isDisabled: Bool {
        switch self {
        case .fill(let style):
            return style.isDisabled
        case .outline(let style):
            return style.isDisabled
        case .image(let style):
            return style.isDisabled
        }
    }
    
    var textColour: Color {
        switch self {
        case .fill(let style):
            return style.foregroundColor
        case .outline(let style):
            return style.foregroundColor
        case .image(let style):
            return .clear
        }
    }
    
    var loaderColor: Color {
        switch self {
        case .fill(let style):
            return style.loaderColor
        case .outline(let style):
            return style.loaderColor
        case .image(let style):
            return style.loaderColor
        }
    }
}
