//
//  WidgetLoadingDelegateTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 06.11.2025..
//

import XCTest
@testable import MobileSDK

@MainActor
class WidgetLoadingDelegateTests: XCTestCase {

    var eventDelegate: WidgetEventDelegateUtil!

    override func setUp() {
        super.setUp()
        eventDelegate = WidgetEventDelegateUtil()
    }

    override func tearDown() {
        eventDelegate = nil
        super.tearDown()
    }

    // MARK: - WidgetEventDelegate Tests

    func testEventDelegateReceivesEvents() {
        // Reset any events from initialization
        eventDelegate.reset()

        // When - This would typically be triggered by user interactions or view model methods
        // For example, if the view model has a method that triggers button events:
        // viewModel.triggerButtonEvent()

        // For demonstration, we'll simulate what the view model would do:
        let mockEvent = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "Test1", action: .click)))
        eventDelegate.widgetEvent(event: mockEvent)

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 1)
        XCTAssertEqual(eventDelegate.lastEvent, mockEvent)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
    }

    func testEventDelegateMultipleEvents() {
        eventDelegate.reset()

        // When - Multiple events are triggered
        let buttonEvent = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "Test1", action: .click)))

        let toggleEvent = WidgetEvent(
            type: .toggle,
            properties: .toggle(WidgetEventToggleProperties(name: "Toggle1", action: .click, state: false)))

        eventDelegate.widgetEvent(event: buttonEvent)
        eventDelegate.widgetEvent(event: toggleEvent)

        // Then
        XCTAssertEqual(eventDelegate.receivedEvents.count, 2)
        XCTAssertEqual(eventDelegate.lastEvent, toggleEvent)
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .button))
        XCTAssertTrue(eventDelegate.hasReceivedEvent(ofType: .toggle))
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .button), 1)
        XCTAssertEqual(eventDelegate.eventsCount(ofType: .toggle), 1)
    }
}
