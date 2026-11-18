//
//  TelemetryResources.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The target's resource bundle, which carries its privacy manifest (`PrivacyInfo.xcprivacy`, R_09). Read by the tests
/// only; `Bundle.module` itself is internal to the target.
package enum TelemetryResources {
    package static var bundle: Bundle { .module }
}
