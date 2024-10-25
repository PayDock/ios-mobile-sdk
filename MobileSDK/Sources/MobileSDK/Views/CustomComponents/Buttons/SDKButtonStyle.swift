//
//  ButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import Foundation

enum SDKButtonStyle {
    
    case fill(FillButtonStyle)
    case outline(OutlineButtonStyle)
    
    var isDisabled: Bool {
        switch self {
        case .fill(let style):
            return style.isDisabled
        case .outline(let style):
            return style.isDisabled
        }
    }
}
