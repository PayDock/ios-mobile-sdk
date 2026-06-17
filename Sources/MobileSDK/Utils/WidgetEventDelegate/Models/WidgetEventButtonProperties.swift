//
//  WidgetEventButtonProperties.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public struct WidgetEventButtonProperties: Codable, Equatable {

    public let name: String
    public let action: WidgetEventActionType
    public let text: String?
    public let formState: WidgetEventFormState?

    init(name: String,
         action: WidgetEventActionType,
         text: String? = nil,
         formState: WidgetEventFormState? = nil) {
        self.name = name
        self.action = action
        self.text = text
        self.formState = formState
    }
}
