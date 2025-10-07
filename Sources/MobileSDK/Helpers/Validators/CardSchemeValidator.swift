//
//  CardIssuerValidator.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 15.08.2023..
//

import Foundation

/**
 A utility object for detecting card schemes based on card numbers
 */
class CardSchemeValidator {

    private let jsonLoader: JSONLoader
    private var binSchemas: [BinSchemaRes.BinSchema]
    private var lastResult: LastBINResult?

    // MARK: - Initialization

    init(jsonLoader: JSONLoader = JSONLoader()) {
        self.jsonLoader = jsonLoader
        self.binSchemas = []
        loadLocalBinSchema()
    }

    // MARK: - Data Loading

    private func loadLocalBinSchema() {
        binSchemas = jsonLoader.loadJSON(filename: "card-schemes", type: BinSchemaRes.self).cardSchemas
    }

    /// Validates card PAN number using Luhn's algorithm.
    ///
    /// - Parameters:
    ///    - number: Card PAN number that contains only digits with or without whitespaces.
    ///    - Returns: true if valid, false otherwise.
    func isPossibleCreditCardNumber(number: String) -> Bool {
        let cleanNumber = number.filter { !$0.isWhitespace }
        guard containsOnlyNumbers(input: cleanNumber), !cleanNumber.isEmpty else { return false }

        let reversedString = cleanNumber.reversed().compactMap { Int(String($0)) }

        var s1 = 0
        var s2 = 0

        for (index, value) in reversedString.enumerated() {

            if index % 2 == 0 {
                s1 += value
            } else {
                let doubled = value * 2
                s2 += (doubled > 9) ? (doubled - 9) : doubled
            }
        }

        return (s1 + s2) % 10 == 0
    }

    private func containsOnlyNumbers(input: String) -> Bool {
        return input.allSatisfy { chr in
            "1234567890".contains(chr)
        }
    }

    func isCardNumberValid(number: String) -> Bool {
        let cardScheme = getCardSchemeFromBIN(cardNumber: number)
        let isCardNumberLengthValid = isCardNumberLengthValid(number: number, scheme: cardScheme)
        let isCardNumberPossible = isPossibleCreditCardNumber(number: number)

        return cardScheme != nil && isCardNumberLengthValid && isCardNumberPossible
    }

    func getCardSchemeFromBIN(cardNumber: String) -> CardScheme? {
        let cleanNumber = cardNumber.filter { !$0.isWhitespace }

        if let cachedSchema = lastResult, cachedSchema.cardNumber == cleanNumber {
            return CardScheme(rawValue: cachedSchema.resolvedScheme ?? "")
        }

        for schema in binSchemas {
            let binParts = schema.bin.split(separator: "~")

            if binParts.count == 1 {
                // Exact match
                if cleanNumber.starts(with: String(binParts[0])) {
                    lastResult = LastBINResult(cardNumber: cleanNumber, resolvedScheme: schema.schema)
                    return CardScheme(rawValue: schema.schema)
                }
            } else if binParts.count == 2 {
                // Range match
                guard let lowerBound = Int(binParts[0]),
                      let upperBound = Int(binParts[1]),
                      let cardPrefix = Int(String(cleanNumber.prefix(binParts[0].count))) else { continue }

                if cardPrefix >= lowerBound && cardPrefix <= upperBound {
                    lastResult = LastBINResult(cardNumber: cleanNumber, resolvedScheme: schema.schema)
                    return CardScheme(rawValue: schema.schema)
                }
            }
        }
        return nil
    }

    // MARK: - Card number length

    func isCardNumberLengthValid(number: String, scheme: CardScheme?) -> Bool {
        guard let scheme = scheme, let regex = cardLengthRegex(for: scheme) else { return false }
        let cleanNumber = number.filter { !$0.isWhitespace }

        let range = NSRange(location: 0, length: cleanNumber.utf16.count)
        let matches = regex.matches(in: cleanNumber, options: [], range: range)

        return !matches.isEmpty
    }

    func isUnknownCardNumberLengthValid(number: String) -> Bool {
        let cleanNumber = number.filter { !$0.isWhitespace }
        return cleanNumber.count >= 12 && cleanNumber.count <= 19
    }

    private func cardLengthRegex(for scheme: CardScheme) -> NSRegularExpression? {
        switch scheme {
        case .amex: return try? NSRegularExpression(pattern: "^\\d{15}$")
        case .diners: return try? NSRegularExpression(pattern: "^\\d{14}$")
        case .visa, .discover: return try? NSRegularExpression(pattern: "^\\d{16,19}$")
        case .mastercard, .japcb: return try? NSRegularExpression(pattern: "^\\d{16}$")
        case .solo, .ausbc: return try? NSRegularExpression(pattern: "^\\d{12,19}$")
        }
    }

    struct LastBINResult {
        var cardNumber: String
        var resolvedScheme: String?
    }
}
