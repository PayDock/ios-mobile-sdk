//
//  NetworkingLibObserverSlot.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import NetworkingLib

/// `NetworkingLib.shared.requestObserver`.
package struct NetworkingLibObserverSlot: RequestObserverSlot {
    package init() {}

    package var current: (any RequestObserver)? {
        NetworkingLib.shared.requestObserver
    }

    package func set(_ observer: any RequestObserver) {
        NetworkingLib.shared.requestObserver = observer
    }
}
