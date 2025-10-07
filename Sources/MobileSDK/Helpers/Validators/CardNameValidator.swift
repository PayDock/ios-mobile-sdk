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
}
