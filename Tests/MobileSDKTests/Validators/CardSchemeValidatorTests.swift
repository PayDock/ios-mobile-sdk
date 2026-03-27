//
//  CardIssuerValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
import BinProcessing

struct CardTestCase {
    let cardNumber: String
    let expectedIssuer: CardScheme
    let isValid: Bool
}

let testCases: [CardTestCase] = [
    // Amex
    CardTestCase(cardNumber: "372015808209082", expectedIssuer: .amex, isValid: true),
    // Visa
    CardTestCase(cardNumber: "4111111111111111", expectedIssuer: .visa, isValid: true),
    // Mastercard
    CardTestCase(cardNumber: "2720994999357329", expectedIssuer: .mastercard, isValid: true),
    CardTestCase(cardNumber: "5555555555554444", expectedIssuer: .mastercard, isValid: true),
    // Diners
    CardTestCase(cardNumber: "30312568541349", expectedIssuer: .diners, isValid: true),
    // JCB
    CardTestCase(cardNumber: "3534429687149385", expectedIssuer: .japcb, isValid: true),
    // Unionpay
    CardTestCase(cardNumber: "6229293072324646", expectedIssuer: .unionpay, isValid: true),
    CardTestCase(cardNumber: "561059108101850", expectedIssuer: .unionpay, isValid: false),
    CardTestCase(cardNumber: "353442987149385", expectedIssuer: .unionpay, isValid: false)
]

class CardSchemeValidatorTests: XCTestCase {

    var validator: CardSchemeValidator!

    override func setUp() {
        super.setUp()
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("BinProcessing detector could not be loaded")
            return
        }
        validator = CardSchemeValidator(binDetector: detector)
    }

    func testIsPossibleCreditCardNumber_ValidNumbers() {
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "4111111111111111")) // Valid Visa
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "378282246310005")) // Valid Amex
    }

    func testIsPossibleCreditCardNumber_InvalidNumbers() {
        XCTAssertFalse(validator.isPossibleCreditCardNumber(number: "1234567890123456")) // Invalid
        XCTAssertFalse(validator.isPossibleCreditCardNumber(number: "4111111111111112")) // Invalid Luhn
    }

    func testIsCardNumberValid_ValidCases() {
        testCases.filter({ $0.isValid }).forEach {
            XCTAssertTrue(validator.isCardNumberValid(number: $0.cardNumber))
        }
    }

    func testIsCardNumberValid_InvalidCases() {
        testCases.filter({ !$0.isValid }).forEach {
            XCTAssertFalse(validator.isCardNumberValid(number: $0.cardNumber))
        }
    }

    func testGetCardSchemeFromBIN_ValidBIN() {
        // BinProcessing card-schemes.json (2/4/6/8-digit prefix and ranges)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "41"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4111"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4988"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "3000"), .diners)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "2221"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "2720"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "34"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "372697"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "644000"), .discover)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622956"), .unionpay)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622970"), .unionpay)
        // 63 -> mastercard, 64 -> discover in BinProcessing data
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "63"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "64"), .discover)
    }

    func testGetCardSchemeFromBIN_InvalidBIN() {
        // BINs that do not match any scheme in BinProcessing card-schemes.json
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "00"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "0012"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "12"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "1212"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "1"))
    }

    func testIsCardNumberLengthValid_ValidLength() {
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 1111 1111", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 444", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 33", scheme: .visa))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .diners))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .mastercard))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .discover))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .japcb))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 1111 1111", scheme: .unionpay))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 444", scheme: .unionpay))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 33", scheme: .unionpay))
    }

    func testIsCardNumberLengthValid_InvalidLength() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 1111 111", scheme: .visa))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 4444", scheme: .visa))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 32", scheme: .visa))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "", scheme: .diners))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .diners))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 123", scheme: .mastercard))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .discover))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 1111", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 111", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .japcb))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 1111 111", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 4444", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 32", scheme: .unionpay))
    }

    // MARK: - Digit Range Tests

    func testDigitRange_Amex() {
        let range = validator.digitRange(for: .amex)
        XCTAssertEqual(range.min, 15)
        XCTAssertEqual(range.max, 15)
    }

    func testDigitRange_Diners() {
        let range = validator.digitRange(for: .diners)
        XCTAssertEqual(range.min, 14)
        XCTAssertEqual(range.max, 14)
    }

    func testDigitRange_Visa() {
        let range = validator.digitRange(for: .visa)
        XCTAssertEqual(range.min, 16)
        XCTAssertEqual(range.max, 19)
    }

    func testDigitRange_Mastercard() {
        let range = validator.digitRange(for: .mastercard)
        XCTAssertEqual(range.min, 16)
        XCTAssertEqual(range.max, 16)
    }

    func testDigitRange_Discover() {
        let range = validator.digitRange(for: .discover)
        XCTAssertEqual(range.min, 16)
        XCTAssertEqual(range.max, 19)
    }

    func testDigitRange_UnionPay() {
        let range = validator.digitRange(for: .unionpay)
        XCTAssertEqual(range.min, 16)
        XCTAssertEqual(range.max, 19)
    }

    func testDigitRange_JCB() {
        let range = validator.digitRange(for: .japcb)
        XCTAssertEqual(range.min, 16)
        XCTAssertEqual(range.max, 16)
    }

    func testDigitRange_UnknownScheme() {
        let range = validator.digitRange(for: nil)
        XCTAssertEqual(range.min, 13)
        XCTAssertEqual(range.max, 19)
    }

    // MARK: - isDigitCountInValidRange Tests

    func testIsDigitCountInValidRange_Amex_Valid() {
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "378282246310005", scheme: .amex)) // 15 digits
    }

    func testIsDigitCountInValidRange_Amex_TooFew() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "37828224631000", scheme: .amex)) // 14 digits
    }

    func testIsDigitCountInValidRange_Amex_TooMany() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "3782822463100051", scheme: .amex)) // 16 digits
    }

    func testIsDigitCountInValidRange_Visa_AtMinimum() {
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "4111111111111111", scheme: .visa)) // 16 digits
    }

    func testIsDigitCountInValidRange_Visa_AtMaximum() {
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "4111111111111111123", scheme: .visa)) // 19 digits
    }

    func testIsDigitCountInValidRange_Visa_BelowMinimum() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "411111111111111", scheme: .visa)) // 15 digits
    }

    func testIsDigitCountInValidRange_Visa_AboveMaximum() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "41111111111111111234", scheme: .visa)) // 20 digits
    }

    func testIsDigitCountInValidRange_WithWhitespace() {
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "4111 1111 1111 1111", scheme: .visa)) // 16 digits with spaces
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "3782 8224 6310 005", scheme: .amex)) // 15 digits with spaces
    }

    func testIsDigitCountInValidRange_UnknownScheme_Valid() {
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "1234567890122", scheme: nil)) // 13 digits (minimum)
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "1234567890123456789", scheme: nil)) // 19 digits (maximum)
    }

    func testIsDigitCountInValidRange_UnknownScheme_BelowMinimum() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "123456789011", scheme: nil)) // 12 digits
    }

    // MARK: - hasMinimumDigits Tests

    func testHasMinimumDigits_Amex_AtMinimum() {
        XCTAssertTrue(validator.hasMinimumDigits(number: "378282246310005", scheme: .amex)) // 15 digits
    }

    func testHasMinimumDigits_Amex_BelowMinimum() {
        XCTAssertFalse(validator.hasMinimumDigits(number: "37828224631000", scheme: .amex)) // 14 digits
    }

    func testHasMinimumDigits_Amex_AboveMinimum() {
        XCTAssertTrue(validator.hasMinimumDigits(number: "3782822463100051", scheme: .amex)) // 16 digits (above min, used for range check)
    }

    func testHasMinimumDigits_Visa_AtMinimum() {
        XCTAssertTrue(validator.hasMinimumDigits(number: "4111111111111111", scheme: .visa)) // 16 digits
    }

    func testHasMinimumDigits_Visa_BelowMinimum() {
        XCTAssertFalse(validator.hasMinimumDigits(number: "411111111111111", scheme: .visa)) // 15 digits
    }

    func testHasMinimumDigits_UnknownScheme_AtMinimum() {
        XCTAssertTrue(validator.hasMinimumDigits(number: "1234567890121", scheme: nil)) // 13 digits
    }

    func testHasMinimumDigits_UnknownScheme_BelowMinimum() {
        XCTAssertFalse(validator.hasMinimumDigits(number: "123456789011", scheme: nil)) // 12 digits
    }

    func testHasMinimumDigits_WithWhitespace() {
        XCTAssertTrue(validator.hasMinimumDigits(number: "4111 1111 1111 1111", scheme: .visa))
        XCTAssertFalse(validator.hasMinimumDigits(number: "4111 1111 1111 111", scheme: .visa)) // 15 digits
    }

    // MARK: - Digit-Only Counting Tests (verifies non-digit characters are not counted)

    func testIsDigitCountInValidRange_IgnoresNonDigitCharacters() {
        // "4111abc1111def1111ghi1111" has 16 digits but also letters
        // Should count only the 16 digits and return true for Visa
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "4111abc1111def1111ghi1111", scheme: .visa))
    }

    func testIsDigitCountInValidRange_WithLetters_StillBelowMinimum() {
        // "411abc111" has only 6 digits plus letters
        // Should count only 6 digits and return false (below 16 minimum for Visa)
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "411abc111", scheme: .visa))
    }

    func testIsDigitCountInValidRange_SpecialCharactersNotCounted() {
        // "4111-1111-1111-1111" has 16 digits with hyphens
        // Should count only 16 digits (not the hyphens)
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "4111-1111-1111-1111", scheme: .visa))
    }

    func testIsDigitCountInValidRange_MixedNonDigitCharacters() {
        // Mix of spaces, letters, symbols - only 15 digits for Amex
        XCTAssertTrue(validator.isDigitCountInValidRange(number: "3782 822a 4631-0005!", scheme: .amex))
    }

    func testHasMinimumDigits_IgnoresNonDigitCharacters() {
        // "4111abc1111def1111ghi1111" has 16 digits
        // Should count only digits and return true for Visa (min 16)
        XCTAssertTrue(validator.hasMinimumDigits(number: "4111abc1111def1111ghi1111", scheme: .visa))
    }

    func testHasMinimumDigits_WithLetters_StillBelowMinimum() {
        // "411abcdefghij111" has only 6 digits plus many letters
        // Should count only 6 digits and return false (below 16 minimum for Visa)
        XCTAssertFalse(validator.hasMinimumDigits(number: "411abcdefghij111", scheme: .visa))
    }

    func testHasMinimumDigits_SpecialCharactersNotCounted() {
        // "123-456-789-012" has 13 digits with hyphens (minimum for unknown scheme)
        XCTAssertTrue(validator.hasMinimumDigits(number: "123-456-789-0123", scheme: nil))
    }

    func testHasMinimumDigits_OnlyLetters_ReturnsZeroDigits() {
        // "abcdefghijklmnop" has 0 digits - should return false for any scheme
        XCTAssertFalse(validator.hasMinimumDigits(number: "abcdefghijklmnop", scheme: .visa))
        XCTAssertFalse(validator.hasMinimumDigits(number: "abcdefghijklmnop", scheme: nil))
    }

    func testIsDigitCountInValidRange_EmptyString() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "", scheme: .visa))
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "", scheme: nil))
    }

    func testHasMinimumDigits_EmptyString() {
        XCTAssertFalse(validator.hasMinimumDigits(number: "", scheme: .visa))
        XCTAssertFalse(validator.hasMinimumDigits(number: "", scheme: nil))
    }

    // MARK: - Additional Min/Max Digit Coverage Tests

    func testIsCardNumberLengthValid_Mastercard_BelowMinimum() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "511111111111111", scheme: .mastercard)) // 15 digits
    }

    func testIsCardNumberLengthValid_Diners_BelowMinimum() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "3031256854134", scheme: .diners)) // 13 digits
    }

    func testIsCardNumberLengthValid_Diners_AboveMaximum() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "303125685413491", scheme: .diners)) // 15 digits
    }

    func testIsCardNumberLengthValid_Discover_BelowMinimum() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "601111111111111", scheme: .discover)) // 15 digits
    }

    func testIsCardNumberLengthValid_Discover_AtMaximum() {
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "6011111111111111111", scheme: .discover)) // 19 digits
    }

    func testIsCardNumberLengthValid_Discover_AboveMaximum() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "60111111111111111111", scheme: .discover)) // 20 digits
    }

    func testIsDigitCountInValidRange_UnknownScheme_AboveMaximum() {
        XCTAssertFalse(validator.isDigitCountInValidRange(number: "12345678901234567890", scheme: nil)) // 20 digits
    }

    // MARK: - Luhn Validation Whitespace Handling Tests

    func testIsPossibleCreditCardNumber_IgnoresWhitespace() {
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "4111 1111 1111 1111")) // With spaces
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "3782 8224 6310 005")) // Amex with spaces
    }

    func testIsPossibleCreditCardNumber_IgnoresMultipleSpaces() {
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "4111  1111  1111  1111")) // Multiple spaces
    }

    func testIsPossibleCreditCardNumber_IgnoresLeadingTrailingSpaces() {
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: " 4111111111111111 ")) // Leading/trailing spaces
    }

    func testIsPossibleCreditCardNumber_InvalidWithWhitespace() {
        XCTAssertFalse(validator.isPossibleCreditCardNumber(number: "4111 1111 1111 1112")) // Invalid Luhn with spaces
    }
}
