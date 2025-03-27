//
//  PayPalDataCollectorUtilTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.11.2024..
//

import XCTest
@testable import MobileSDK

class PayPalDataCollectorUtilTests: XCTestCase {
    
    var mockConfig: PayPalDataCollectorConfig!
    var mockService: PayPalVaultServiceMock!
    
    override func setUp() {
        super.setUp()
        mockConfig = PayPalDataCollectorConfig(accessToken: "testAccessToken", gatewayId: "testGateway")
        mockService = PayPalVaultServiceMock()
        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))
    }
    
    func testInitializeDataCollector_Success() async throws {
        let util = try await PayPalDataCollectorUtil.initialise(config: mockConfig, service: mockService)
        
        XCTAssertNotNil(util)
        XCTAssertEqual(util.clientId, "AY-iOYV1QKAX6ZRomt-gXigd0-pToRMwdoLW4UxFSITOApI2jUa5UgM39MKC0qeip3SCbPozbAusuGO0", "Client ID should match the expected mock client ID.")
    }
    
    func testInitializeDataCollectorFail() async throws {
        mockService.sendError = true
        
        do {
            _ = try await PayPalDataCollectorUtil.initialise(config: mockConfig, service: mockService)
            XCTFail("Expected to throw PayPalDataCollectorError.initialisationClientId, but succeeded.")
        } catch let error as PayPalDataCollectorError {
            if case .initialisationClientId = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testCollectDeviceDataEmpty() {
        let config = PayPalDataCollectorConfig(accessToken: "testAccessToken", gatewayId: "testGateway")
        let clientId = "testClientID"
        let util = PayPalDataCollectorUtil(config: config, clientId: clientId)
        
        let deviceData = util.collectDeviceData(additionalData: [:])
        
        XCTAssertFalse(deviceData.isEmpty, "Device data should not be empty.")
    }
    
    func testCollectDeviceDataWithAdditionalData() {
        let config = PayPalDataCollectorConfig(accessToken: "testAccessToken", gatewayId: "testGateway")
        let clientId = "testClientID"
        let util = PayPalDataCollectorUtil(config: config, clientId: clientId)
        
        let additionalData: [String: String] = ["key1": "value1", "key2": "value2"]
        let deviceData = util.collectDeviceData(additionalData: additionalData)
        
        XCTAssertFalse(deviceData.isEmpty, "Device data should not be empty.")
    }
}
