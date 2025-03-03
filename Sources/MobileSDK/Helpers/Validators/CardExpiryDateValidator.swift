//
//  CardExpiryDateValidator.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardExpiryDateValidatior {

    func validateCreditCardExpiry(stringDate: String) -> ExpiryValidation {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"

        guard let enteredDate = dateFormatter.date(from: stringDate),
              let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: enteredDate) else {
            return .invalidInput
        }

        let now = Date()
        if (endOfMonth < now) {
            return .expired
        } else {
            return .valid
        }
    }

    enum ExpiryValidation {
        case valid, invalidInput, expired
    }

}
