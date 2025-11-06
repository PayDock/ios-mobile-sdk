//
//  WidgetEventType.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public enum WidgetEventType: String, Codable, CaseIterable {

    case button = "Button"
    case toggle = "Toggle"
    case linkText = "LinkText"
}
