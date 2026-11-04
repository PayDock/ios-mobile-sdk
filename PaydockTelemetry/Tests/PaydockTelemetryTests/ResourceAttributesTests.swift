//
//  ResourceAttributesTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class ResourceAttributesTests: XCTestCase {

    func testAsMap_HasExactlyTheFourteenKeys_WithTheDocumentedTypes() {
        let map = FakeDeviceContextProvider.attributes.asMap()

        XCTAssertEqual(map.count, 14)
        XCTAssertEqual(map, [
            "service.name": .string("paydock-mobile-sdk"),
            "service.namespace": .string("paydock"),
            "service.version": .string("0.0.0-test"),
            "paydock.sdk.platform": .string("ios"),
            "paydock.telemetry.spec_version": .int(1),
            "deployment.environment.name": .string("sandbox"),
            "os.name": .string("iOS"),
            "os.version": .string("17.0"),
            "device.manufacturer": .string("Apple"),
            "device.model.identifier": .string("iPhone15,2"),
            "app.installation.id": .string(FakeDeviceContextProvider.installationId),
            "paydock.app.id": .string("com.paydock.sample"),
            "paydock.app.version": .string("1.0.0"),
            "paydock.app.debuggable": .bool(true)
        ])
    }
}
