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
        if endOfMonth < now {
            return .expired
        } else {
            return .valid
        }
    }

    /// Validates the month portion (first 2 digits) of the expiry date
    func validateMonth(month: String) -> Bool {
        guard month.count == 2,
              let monthInt = Int(month),
              monthInt >= 1 && monthInt <= 12 else {
            return false
        }
        return true
    }

    /// Extracts the month from a formatted expiry string (MM/YY or MM)
    func extractMonth(from expiryText: String) -> String? {
        let digits = expiryText.filter { $0.isNumber }
        guard digits.count >= 2 else { return nil }
        return String(digits.prefix(2))
    }

    /// Extracts the digit count from a formatted expiry string
    func digitCount(from expiryText: String) -> Int {
        return expiryText.filter { $0.isNumber }.count
    }

    enum ExpiryValidation {
        case valid, invalidInput, expired
    }

}
