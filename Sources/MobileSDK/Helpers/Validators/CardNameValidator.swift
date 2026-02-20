//
//  CardNameValidator.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.07.2025..
//  Copyright © 2025 Paydock Ltd.
//

class CardNameValidator {

    func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"^\p{L}(?:[\p{L}'`.\-]*(?: [\p{L}'`.\-]+)*)$"#
        return trimmed.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Checks if the input contains only characters allowed in a cardholder name.
    /// Allowed: Unicode letters, space, apostrophe, backtick, period, hyphen.
    /// Used for active validation during typing.
    func containsOnlyAllowedCharacters(_ name: String) -> Bool {
        let allowedPattern = #"^[\p{L} '`.\-]*$"#
        return name.range(of: allowedPattern, options: .regularExpression) != nil
    }

    /// Checks if the name starts with a letter (required for valid names).
    /// Used for active validation after first character is entered.
    func startsWithLetter(_ name: String) -> Bool {
        guard let firstChar = name.first else { return true }
        return firstChar.isLetter
    }
}
