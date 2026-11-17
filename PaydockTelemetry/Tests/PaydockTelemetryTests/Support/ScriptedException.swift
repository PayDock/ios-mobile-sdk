//
//  ScriptedException.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// An exception with set return addresses, as a raised one would carry: Swift can't raise and catch one to get them.
final class ScriptedException: NSException, @unchecked Sendable {
    private let addresses: [NSNumber]

    init(name: String, reason: String? = nil, userInfo: [AnyHashable: Any]? = nil, addresses: [UInt]) {
        self.addresses = addresses.map { NSNumber(value: $0) }
        super.init(name: NSExceptionName(name), reason: reason, userInfo: userInfo)
    }

    required init?(coder: NSCoder) {
        addresses = []
        super.init(coder: coder)
    }

    override var callStackReturnAddresses: [NSNumber] { addresses }
}
