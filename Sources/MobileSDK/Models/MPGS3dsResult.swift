//
//  Integrated3DSResult.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.12.2023..
//

import Foundation

public struct MPGS3dsResult {

    public let event: EventType
    public let charge3dsId: String

    public enum EventType: String {
        case chargeAuthSuccess
        case chargeAuthReject
        case chargeAuthCancelled
        case additionalDataCollectSuccess
        case additionalDataCollectReject
        case chargeAuth
    }
}
