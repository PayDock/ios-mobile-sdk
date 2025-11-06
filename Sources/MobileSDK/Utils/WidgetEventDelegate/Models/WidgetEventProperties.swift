//
//  WidgetEventProperties.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public enum WidgetEventProperties: Codable, Equatable {

    case button(WidgetEventButtonProperties)
    case toggle(WidgetEventToggleProperties)
    case linkText(WidgetEventLinkTextProperties)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .button(let properties):
            try properties.encode(to: encoder)
        case .toggle(let properties):
            try properties.encode(to: encoder)
        case .linkText(let properties):
            try properties.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        if container.contains(DynamicCodingKey(stringValue: "state")!) {
            self = .toggle(try WidgetEventToggleProperties(from: decoder))
        } else if container.contains(DynamicCodingKey(stringValue: "url")!) {
            self = .linkText(try WidgetEventLinkTextProperties(from: decoder))
        } else {
            self = .button(try WidgetEventButtonProperties(from: decoder))
        }
    }
}
