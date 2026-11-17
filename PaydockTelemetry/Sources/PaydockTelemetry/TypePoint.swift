//
//  TypePoint.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One Swift type of the loaded image: its metadata accessor's place in the image and the module that declares it
/// (spec § 7.2).
package struct TypePoint: Sendable, Equatable {
    package let offset: UInt64        // the metadata accessor's offset from the image's load address
    package let module: String

    package init(offset: UInt64, module: String) {
        self.offset = offset
        self.module = module
    }
}
