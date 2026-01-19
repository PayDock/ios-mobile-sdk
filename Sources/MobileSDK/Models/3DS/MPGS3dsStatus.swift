//
//  Integrated3DSStatus.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.02.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

enum MPGS3dsStatus: String {
    case rejected
    case authenticated
    case notAuthenticated = "not_authenticated"
    case additionalDataComplete = "additional_data_complete"
    case additionalDataFailed = "additional_data_failed"
    case authenticationCancelled = "authentication_cancelled"
}
