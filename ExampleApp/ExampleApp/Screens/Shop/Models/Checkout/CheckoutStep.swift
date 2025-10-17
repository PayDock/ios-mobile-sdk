//
//  CheckoutStep.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 06.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

enum CheckoutStep: CaseIterable {
    case information
    case paymentAndReview

    var title: String {
        switch self {
        case .information: return "Information"
        case .paymentAndReview: return "Payment & Review"
        }
    }
}
