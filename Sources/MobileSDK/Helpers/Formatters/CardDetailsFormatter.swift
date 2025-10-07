//
//  CardExpiryDateFormatter.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardDetailsFormatter {

    // MARK: - Bank Card

    func formatCardNumber(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        var groomed = ""
        var newCursorPosition = cursorPosition
        var originalIndex = 0

        for char in updatedText {
            if char == " " && (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19) {
                groomed.append(char)
            } else if char.isASCII && char.isNumber {
                if groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19 {
                    groomed.append(" ")
                    // If cursor was at or after this position, adjust it
                    if originalIndex < cursorPosition {
                        newCursorPosition += 1
                    }
                }
                groomed.append(char)
            }
            originalIndex += 1
            if groomed.count == 23 {
                break
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
