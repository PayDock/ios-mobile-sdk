//
//  RequestObserverSlot.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import NetworkingLib

/// Where a request observer is registered: the library's single slot, or a test double.
package protocol RequestObserverSlot: Sendable {
    var current: (any RequestObserver)? { get }
    func set(_ observer: any RequestObserver)
}
