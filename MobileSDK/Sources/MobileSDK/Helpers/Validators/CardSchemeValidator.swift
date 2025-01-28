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
    
    private let cardService: CardService
    private let cardServiceMock: CardService
    private var binSchemas: [BinSchemaRes.BinSchema]
    
    // MARK: - Initialization
    
    init(cardService: CardService = CardServiceImpl(), cardServiceMock: CardService = CardServiceMock()) {
        self.cardService = cardService
        self.cardServiceMock = cardServiceMock
        self.binSchemas = []
        
        loadLocalBin()
        loadRemoteBin()
    }
    
    // MARK: - Data Loading
    
    private func loadLocalBin() {
        Task {
            do {
                binSchemas =  try await cardServiceMock.getCardBinSchema(accessToken: "")
                print("success loading bin")
            } catch {
                print(error)
                print("Error loading local BIN .json!")
            }
        }
    }
    
    private func loadRemoteBin() {
        Task {
            do {
                binSchemas =  try await cardService.getCardBinSchema(accessToken: "")
            } catch {
                print("Error loading remote BIN .json!")
            }
        }
    }
    
    private func cardLengthRegex(for scheme: CardScheme) -> NSRegularExpression? {
        switch scheme {
        case .amex: return try? NSRegularExpression(pattern: "^\\d{15}$")
        case .diners: return try? NSRegularExpression(pattern: "^\\d{14}|\\d{16}$")
        case .visa: return try? NSRegularExpression(pattern: "^\\d{13}(\\d{3})?(\\d{3})?$")
        case .mastercard: return try? NSRegularExpression(pattern: "^\\d{15}$")
        case .discover: return try? NSRegularExpression(pattern: "^\\d{16}$")
        case .japcb, .solo, .ausbc: return try? NSRegularExpression(pattern: "^\\d{16,19}$")
        }
    }

    /// Validates card PAN number using Luhn's algorithm.
    ///
    /// - Parameters:
    ///    - number: Card PAN number that contains only digits with or without whitespaces.
    ///    - Returns: true if valid, false otherwise.
    func isPotentialCreditCardNumber(number: String) -> Bool {
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
    
//    func isCardNumberValid(number: String) -> Bool {
//        let isValidBin = getCardSchemeFromBIN(cardNumber: number)
//        let isCardNumberLengthValid = isCardNumberLengthValid(number: number, scheme: isValidBin)
//        
//        return isValidBin != nil && isCardNumberLengthValid
//    }
    
    func getCardSchemeFromBIN(cardNumber: String) -> CardScheme? {
        let cleanNumber = cardNumber.filter { !$0.isWhitespace }
        print("ASD")
        
        for schema in binSchemas {
            let binParts = schema.bin.split(separator: "~")
            
            if binParts.count == 1 {
                // Exact match
                if cleanNumber.starts(with: String(binParts[0])) {
                    return CardScheme(rawValue: schema.schema)
                }
            } else if binParts.count == 2 {
                // Range match
                guard let lowerBound = Int(binParts[0]),
                      let upperBound = Int(binParts[1]),
                      let cardPrefix = Int(String(cleanNumber.prefix(binParts[0].count))) else { continue }
                
                if cardPrefix >= lowerBound && cardPrefix <= upperBound {
                    return CardScheme(rawValue: schema.schema)
                }
            }
        }
        return nil
    }
    
    func isCardNumberLengthValid(number: String, scheme: CardScheme?) -> Bool {
        guard let scheme = scheme, let regex = cardLengthRegex(for: scheme) else { return false }
        let cleanNumber = number.filter { !$0.isWhitespace }
        
        let range = NSRange(location: 0, length: cleanNumber.utf16.count)
        let matches = regex.matches(in: cleanNumber, options: [], range: range)
        
        return !matches.isEmpty
    }
}
