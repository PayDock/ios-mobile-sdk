//
//  AddressWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

public struct AddressWidgetConfig {

    /// Pass as `address` object in order to prefill known fields
    public let address: Address?

    /// Specifies whether the primary button (e.g., Add) should be enabled by default.
    /// If `true`, the button is always enabled, and validation is performed upon clicking it.
    /// If `false`, the button remains disabled until all fields are valid. Defaults to `true`.
    public let activePrimaryButton: Bool

    public init(address: Address? = nil,
                activePrimaryButton: Bool = true) {
        self.address = address
        self.activePrimaryButton = activePrimaryButton
    }
}
