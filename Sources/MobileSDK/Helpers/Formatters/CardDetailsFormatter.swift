//
//  CardExpiryDateFormatter.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardDetailsFormatter {

    // MARK: - Card Number Spacing Patterns

    /// Space positions for different card schemes (digit count after which to insert space)
    enum CardSpacingPattern {
        case standard   // 4-4-4-4-3: spaces after digits 4, 8, 12, 16
        case amex       // 4-6-5: spaces after digits 4, 10
        case diners     // 4-6-4: spaces after digits 4, 10

        var spaceAfterDigits: Set<Int> {
            switch self {
            case .standard: return [4, 8, 12, 16]
            case .amex: return [4, 10]
            case .diners: return [4, 10]
            }
        }
    }

    // MARK: - Bank Card

    func formatCardNumber(
        updatedText: String,
        cursorPosition: Int,
        maxDigits: Int,
        spacingPattern: CardSpacingPattern = .standard
    ) -> (formattedText: String, newCursorPosition: Int) {
        let spacePositions = spacingPattern.spaceAfterDigits

        // First, calculate cursor position in terms of digit count (ignoring spaces)
        var digitCountBeforeCursor = 0
        var charIndex = 0
        for char in updatedText {
            if charIndex >= cursorPosition {
                break
            }
            if char.isASCII && char.isNumber {
                digitCountBeforeCursor += 1
            }
            charIndex += 1
        }

        // Now build the formatted string
        var groomed = ""
        var digitCount = 0

        for char in updatedText {
            // Stop if we've reached max digits
            if digitCount >= maxDigits {
                break
            }

            if char.isASCII && char.isNumber {
                // Insert space if we've reached a space position
                if spacePositions.contains(digitCount) && digitCount > 0 {
                    groomed.append(" ")
                }
                groomed.append(char)
                digitCount += 1
            }
        }

        // Calculate new cursor position based on digit count before cursor
        var newCursorPosition = 0
        var digitsEncountered = 0
        for char in groomed {
            if digitsEncountered >= digitCountBeforeCursor {
                break
            }
            newCursorPosition += 1
            if char.isNumber {
                digitsEncountered += 1
            }
        }

        // Ensure cursor position doesn't exceed the formatted text length
        newCursorPosition = min(newCursorPosition, groomed.count)

        return (formattedText: groomed, newCursorPosition: newCursorPosition)
    }

    func formatExpiryDate(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        var groomed = ""
        var digitCount = 0
        var originalIndex = 0
        var newCursorPosition: Int?

        for char in updatedText {
            if char == "/" {
                if groomed.count == 2 && groomed.last != "/" {
                    groomed.append("/")
                }
            } else if char.isWholeNumber {
                if digitCount == 2 && groomed.last != "/" {
                    groomed.append("/")
                    if newCursorPosition == nil && originalIndex == cursorPosition {
                        newCursorPosition = groomed.count - 1
                    }
                }
                groomed.append(char)
                digitCount += 1
            }

            if newCursorPosition == nil && originalIndex + 1 == cursorPosition {
                newCursorPosition = groomed.count
            }

            originalIndex += 1
            if groomed.count == 5 { break } // "MM/YY"
        }

        // Special case: cursor was at very start
        if cursorPosition == 0 {
            newCursorPosition = 0
        }

        if newCursorPosition == nil {
            newCursorPosition = groomed.count
        }

        return (groomed, newCursorPosition!)
    }

    func formatSecurityCode(updatedText: String, cursorPosition: Int, maxDigits: Int) -> (formattedText: String, newCursorPosition: Int) {
        var groomed = ""
        var newCursorPosition = cursorPosition
        var originalIndex = 0
        var digitCount = 0

        for char in updatedText {
            if char.isASCII && char.isNumber {
                // Stop if we already have maxDigits
                if digitCount == maxDigits { break }

                groomed.append(char)
                digitCount += 1
            }

            if originalIndex < cursorPosition {
                newCursorPosition = groomed.count
            }

            originalIndex += 1
        }

        // Ensure cursor position doesn't exceed formatted length
        newCursorPosition = min(newCursorPosition, groomed.count)

        return (formattedText: groomed, newCursorPosition: newCursorPosition)
    }

    // MARK: - Gift Card

    func formatGiftCardNumber(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        var groomed = ""
        var newCursorPosition = cursorPosition
        var originalIndex = 0
        var digitCount = 0

        for char in updatedText {
            if char.isASCII && char.isNumber {
                // Stop if we already have 25 digits
                if digitCount == 25 { break }

                // Insert space every 4 digits (except before the first digit)
                if digitCount > 0 && digitCount % 4 == 0 {
                    groomed.append(" ")
                    if originalIndex < cursorPosition {
                        newCursorPosition += 1
                    }
                }

                groomed.append(char)
                digitCount += 1
            }

            originalIndex += 1
        }

        // Ensure cursor position doesn't exceed the formatted text length
        newCursorPosition = min(newCursorPosition, groomed.count)

        return (formattedText: groomed, newCursorPosition: newCursorPosition)
    }

    func formatGiftCardPin(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        var groomed = ""
        var newCursorPosition = cursorPosition
        var originalIndex = 0
        var digitCount = 0

        for char in updatedText {
            if char.isASCII && char.isNumber {
                // Stop if we already have 4 digits
                if digitCount == 4 { break }

                groomed.append(char)
                digitCount += 1
            }

            if originalIndex < cursorPosition {
                newCursorPosition = groomed.count
            }

            originalIndex += 1
        }

        // Ensure cursor position doesn't exceed formatted length
        newCursorPosition = min(newCursorPosition, groomed.count)

        return (formattedText: groomed, newCursorPosition: newCursorPosition)
    }
}
