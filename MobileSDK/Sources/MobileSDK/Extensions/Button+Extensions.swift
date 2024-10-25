//
//  Button+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import SwiftUI

extension Button {
    
    @ViewBuilder
    func myStyle(_ style: SDKButtonStyle) -> some View {
        switch style {
        case .fill(let style):
            self.buttonStyle(style)
        case .outline(let style):
            self.buttonStyle(style)
        }
    }
}
