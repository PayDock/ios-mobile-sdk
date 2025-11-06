//
//  WidgetEventButtonProperties.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct WidgetEventButtonProperties: Codable, Equatable {

    public let name: String
    public let action: WidgetEventActionType
    public let text: String?

    init(name: String, action: WidgetEventActionType, text: String? = nil) {
        self.name = name
        self.action = action
        self.text = text
    }
}
