//
//  WidgetEvent.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct WidgetEvent: Codable, Equatable {

    public let type: WidgetEventType
    public let properties: WidgetEventProperties
}
