//
//  ClickToPayWidgetConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.05.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct ClickToPayWidgetConfig {

    public let serviceId: String
    public let accessToken: String
    public let meta: ClickToPayMeta?

    public init(serviceId: String, accessToken: String, meta: ClickToPayMeta?) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        self.meta = meta
    }
}
