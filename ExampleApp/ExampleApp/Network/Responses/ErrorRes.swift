//
//  ErrorRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct ErrorRes: Codable {

    let status: Int
    let error: ErrorObj?
    let resource: Resource?
    let errorSummary: ErrorSummary?

    struct ErrorObj: Codable {
        let message: String?
        let code: String?
    }

    struct Resource: Codable {
        let type: String?
    }

    struct ErrorSummary: Codable {
        let message: String?
        let code: String?
    }

}
