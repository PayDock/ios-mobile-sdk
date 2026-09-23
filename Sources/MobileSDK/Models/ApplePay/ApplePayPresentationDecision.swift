//
//  ApplePayPresentationDecision.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Called on the main actor when the Apple Pay button is tapped, before the payment sheet is presented.
/// Return `true` to present the sheet, or `false` to skip it silently (`completion` is not called).
/// There is no SDK-side timeout.
public typealias ApplePayPresentationDecision = @MainActor () async -> Bool
