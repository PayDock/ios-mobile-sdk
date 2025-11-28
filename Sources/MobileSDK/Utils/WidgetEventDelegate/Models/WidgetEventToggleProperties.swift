//
//  WidgetEventToggleProperties.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct WidgetEventToggleProperties: Codable, Equatable {

    public let name: String
    public let action: WidgetEventActionType
    public let state: Bool
}
