//
//  AfterpayCallbackRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import Foundation
import NetworkingLib

struct AfterpayCallbackRes: Codable {
    let status: Int
    let error: ErrorRes?
    let resource: AfterpayResource
}
