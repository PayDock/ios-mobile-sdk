//
//  File.swift
//  
//
//  Created by Domagoj Grizelj on 28.07.2023..
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
