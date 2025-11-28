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

    public var jsonDescription: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8) ?? "Failed to encode"
        } catch {
            return "Encoding error: \(error.localizedDescription)"
        }
    }
}
