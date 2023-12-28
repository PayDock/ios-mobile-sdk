//
//  CheckoutPaymentVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.12.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

class CheckoutPaymentVM: ObservableObject {

    @Published var selectedMethod: PaymentMethod = .card

    enum PaymentMethod {
        case card
        case applePay
        case payPal
    }

}
