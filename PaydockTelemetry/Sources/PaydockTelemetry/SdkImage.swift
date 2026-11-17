//
//  SdkImage.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The loaded image that holds the SDK's code: the app's executable when the SDK is linked statically, a framework
/// when it is dynamic.
package struct SdkImage: Sendable, Equatable {
    package let name: String         // last path component
    package let uuid: String         // LC_UUID, uppercase with dashes
    package let loadAddress: UInt    // the mach header's address

    package init(name: String, uuid: String, loadAddress: UInt) {
        self.name = name
        self.uuid = uuid
        self.loadAddress = loadAddress
    }
}
