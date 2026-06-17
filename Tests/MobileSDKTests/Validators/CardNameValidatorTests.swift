//
//  CardNameValidatorTests.swift
//  MobileSDKTests
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

final class CardNameValidatorTests: XCTestCase {

    var sut: CardNameValidator!

    override func setUp() {
        super.setUp()
        sut = CardNameValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - isValidName Tests

    func testIsValidName_ValidSimpleName() {
        XCTAssertTrue(sut.isValidName("John Doe"))
    }

    func testIsValidName_ValidSingleName() {
        XCTAssertTrue(sut.isValidName("John"))
    }

    func testIsValidName_ValidNameWithApostrophe() {
        XCTAssertTrue(sut.isValidName("O'Brien"))
    }

    func testIsValidName_ValidNameWithCurlyApostrophe() {
        // iOS smart punctuation substitutes a straight apostrophe (') with a curly one (U+2019),
        // so names like "D’Angelo" must still be accepted.
        XCTAssertTrue(sut.isValidName("D\u{2019}Angelo"))
    }

    func testIsValidName_ValidNameWithHyphen() {
        XCTAssertTrue(sut.isValidName("Mary-Jane"))
    }

    func testIsValidName_ValidNameWithPeriod() {
        XCTAssertTrue(sut.isValidName("Dr. Smith"))
    }

    func testIsValidName_ValidNameWithMultipleSpaces() {
        XCTAssertTrue(sut.isValidName("Jean Claude Van Damme"))
    }

    func testIsValidName_ValidUnicodeName() {
        XCTAssertTrue(sut.isValidName("José García"))
    }

    func testIsValidName_InvalidEmpty() {
        XCTAssertFalse(sut.isValidName(""))
    }

    func testIsValidName_InvalidOnlySpaces() {
        XCTAssertFalse(sut.isValidName("   "))
    }

    func testIsValidName_InvalidStartsWithNumber() {
        XCTAssertFalse(sut.isValidName("1John"))
    }

    func testIsValidName_InvalidContainsNumbers() {
        XCTAssertFalse(sut.isValidName("John123"))
    }

    func testIsValidName_ValidWithLeadingSpace_IsTrimmed() {
        // isValidName trims whitespace, so " John" becomes "John" which is valid
        XCTAssertTrue(sut.isValidName(" John"))
    }

    func testIsValidName_InvalidSpecialCharacters() {
        XCTAssertFalse(sut.isValidName("John@Doe"))
    }

    // MARK: - containsOnlyAllowedCharacters Tests

    func testContainsOnlyAllowedCharacters_ValidLettersOnly() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("John"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithSpace() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("John Doe"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithApostrophe() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("O'Brien"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithCurlyApostrophe() {
        // The curly apostrophe (U+2019) produced by iOS smart punctuation must be allowed.
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("D\u{2019}Angelo"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithHyphen() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("Mary-Jane"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithPeriod() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("Dr. Smith"))
    }

    func testContainsOnlyAllowedCharacters_ValidWithBacktick() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("O`Brien"))
    }

    func testContainsOnlyAllowedCharacters_ValidEmpty() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters(""))
    }

    func testContainsOnlyAllowedCharacters_ValidUnicode() {
        XCTAssertTrue(sut.containsOnlyAllowedCharacters("José García"))
    }

    func testContainsOnlyAllowedCharacters_InvalidWithNumbers() {
        XCTAssertFalse(sut.containsOnlyAllowedCharacters("John123"))
    }

    func testContainsOnlyAllowedCharacters_InvalidWithAtSymbol() {
        XCTAssertFalse(sut.containsOnlyAllowedCharacters("john@doe"))
    }

    func testContainsOnlyAllowedCharacters_InvalidWithExclamation() {
        XCTAssertFalse(sut.containsOnlyAllowedCharacters("John!"))
    }

    func testContainsOnlyAllowedCharacters_InvalidWithUnderscore() {
        XCTAssertFalse(sut.containsOnlyAllowedCharacters("John_Doe"))
    }

    // MARK: - startsWithLetter Tests

    func testStartsWithLetter_ValidStartsWithLetter() {
        XCTAssertTrue(sut.startsWithLetter("John"))
    }

    func testStartsWithLetter_ValidStartsWithUnicodeLetter() {
        XCTAssertTrue(sut.startsWithLetter("José"))
    }

    func testStartsWithLetter_ValidEmpty() {
        XCTAssertTrue(sut.startsWithLetter(""))
    }

    func testStartsWithLetter_InvalidStartsWithNumber() {
        XCTAssertFalse(sut.startsWithLetter("1John"))
    }

    func testStartsWithLetter_InvalidStartsWithSpace() {
        XCTAssertFalse(sut.startsWithLetter(" John"))
    }

    func testStartsWithLetter_InvalidStartsWithApostrophe() {
        XCTAssertFalse(sut.startsWithLetter("'Brien"))
    }

    func testStartsWithLetter_InvalidStartsWithHyphen() {
        XCTAssertFalse(sut.startsWithLetter("-Jane"))
    }
}
