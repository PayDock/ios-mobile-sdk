//
//  NoOpAddressResolver.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Resolves nothing: every address gives nil.
package struct NoOpAddressResolver: AddressResolving {
    package init() {}
    package func resolve(_ address: UInt) -> ResolvedAddress? { nil }
}
