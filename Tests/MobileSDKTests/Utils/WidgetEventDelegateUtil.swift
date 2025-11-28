//
//  WidgetEventDelegateUtil.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 06.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

@MainActor
class WidgetEventDelegateUtil: WidgetEventDelegate {

    public var receivedEvents: [WidgetEvent] = []
    public var lastEvent: WidgetEvent?

    func widgetEvent(event: WidgetEvent) {
        receivedEvents.append(event)
        lastEvent = event
    }

    // Convenience methods for testing
    func reset() {
        receivedEvents.removeAll()
        lastEvent = nil
    }

    func hasReceivedEvent(ofType type: WidgetEventType) -> Bool {
        return receivedEvents.contains { $0.type == type }
    }

    func eventsCount(ofType type: WidgetEventType) -> Int {
        return receivedEvents.filter { $0.type == type }.count
    }
}
