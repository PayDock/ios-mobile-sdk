//
//  WidgetEventToggleProperties.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public struct WidgetEventToggleProperties: Codable, Equatable {

    public let name: String
    public let action: WidgetEventActionType
    public let state: Bool
}
