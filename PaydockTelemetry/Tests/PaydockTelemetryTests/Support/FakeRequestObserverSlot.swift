//
//  FakeRequestObserverSlot.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry

/// A request observer slot of its own, so registration is tested without touching NetworkingLib's. Counts every set.
/// With `alsoSetsTheLibrary`, a set also puts the observer in `NetworkingLib.shared.requestObserver`, so a real
/// `HTTPClient` reports to it; `restoreTheLibrary()` puts back the library's observer from before the first set.
final class FakeRequestObserverSlot: RequestObserverSlot, @unchecked Sendable {
    private let lock = NSLock()
    private let alsoSetsTheLibrary: Bool
    private var observer: (any RequestObserver)?
    private var libraryObserverBefore: (any RequestObserver)?
    private var sets = 0

    init(_ observer: (any RequestObserver)? = nil, alsoSetsTheLibrary: Bool = false) {
        self.observer = observer
        self.alsoSetsTheLibrary = alsoSetsTheLibrary
    }

    var setCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return sets
    }

    var current: (any RequestObserver)? {
        lock.lock()
        defer { lock.unlock() }
        return observer
    }

    func set(_ observer: any RequestObserver) {
        lock.lock()
        defer { lock.unlock() }
        if alsoSetsTheLibrary {
            if sets == 0 {
                libraryObserverBefore = NetworkingLib.shared.requestObserver
            }
            NetworkingLib.shared.requestObserver = observer
        }
        sets += 1
        self.observer = observer
    }

    func restoreTheLibrary() {
        lock.lock()
        defer { lock.unlock() }
        if alsoSetsTheLibrary, sets > 0 {
            NetworkingLib.shared.requestObserver = libraryObserverBefore
        }
    }
}
