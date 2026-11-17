//
//  AddressResolving.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Resolves a return address to its image and symbol; nil when no loaded image holds it.
package protocol AddressResolving: Sendable { func resolve(_ address: UInt) -> ResolvedAddress? }
