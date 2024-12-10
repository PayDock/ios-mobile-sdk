//
//  CreateCustomerTokenRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct CreateCustomerTokenRes: Codable {
    
    let status: Int
    let error: String?
    let resource: Resource
    
    struct Resource: Codable {
        let type: String
        let data: CustomerData
        
        struct CustomerData: Codable {
            let companyId: String
            let firstName: String
            let lastName: String
            let email: String
            let phone: String
            let _checkExpireDate: Bool
            let _service: Service
            let statistics: Statistics
            let archived: Bool
            let status: String
            let paymentSources: [PaymentSource]
            let defaultSource: String
            let _sourceIpAddress: String
            let _id: String
            let paymentDestinations: [String]
            let updatedAt: String
            let createdAt: String
            let __v: Int
            
            struct Service: Codable {
                let defaultGatewayId: String
            }
            
            struct Statistics: Codable {
                let successfulTransactions: Int
                let totalCollectedAmount: Int
                
            }
            
            struct PaymentSource: Codable {
                let type: String
                let checkoutHolder: String
                let checkoutEmail: String
                let externalPayerId: String
                let status: String
                let gatewayId: String
                let gatewayName: String
                let gatewayType: String
                let gatewayMode: String
                let createdAt: String
                let updatedAt: String
                let refToken: String
                let _id: String
            }
        }
    }
}
