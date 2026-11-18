//
//  DebugStandInHosts.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
/// R_02, R_12: the example app's timeout and offline triggers point the SDK's API host here for one call; a new host
/// each time, so no pooled connection is reused (A16 P6). Debug builds only: a release binary holds neither.
package enum DebugStandInHosts {
    package static let timeout = "10.255.255.1"      // non-routable: the connection times out
    package static let refused = "127.0.0.1"         // closed loopback port: the connection is refused
    package static let all: Set<String> = [timeout, refused]
}
#endif
