//
//  DladdrAddressResolver.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// `dladdr`: the image's path (`dli_fname`) and load address (`dli_fbase`), and the nearest exported symbol below the
/// address (`dli_sname`, `dli_saddr`) when there is one. Not a required-reason API (D16).
package struct DladdrAddressResolver: AddressResolving {
    package init() {}

    package func resolve(_ address: UInt) -> ResolvedAddress? {
        var info = Dl_info()
        guard let pointer = UnsafeRawPointer(bitPattern: address), dladdr(pointer, &info) != 0,
              let path = info.dli_fname, let base = info.dli_fbase else {
            return nil
        }
        let symbol = info.dli_sname.map { String(cString: $0) }
        return ResolvedAddress(imagePath: String(cString: path), imageLoadAddress: UInt(bitPattern: base),
                               symbol: symbol?.isEmpty == false ? symbol : nil,
                               symbolAddress: info.dli_saddr.map { UInt(bitPattern: $0) })
    }
}
