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
        var newCursorPosition = cursorPosition
        var originalIndex = 0
        var digitCount = 0

        for char in updatedText {
            if char == "/" {
                // Accept a slash only if it belongs at position 2 and there's not already one
                if groomed.count == 2 && groomed.last != Character("/") {
                    groomed.append(char)
                    if originalIndex < cursorPosition {
                        newCursorPosition += 1
                    }
                }
            } else if char.isASCII && char.isNumber {
                // Insert slash before the 3rd digit only if we don't already have one
                if digitCount == 2 && groomed.last != Character("/") {
                    groomed.append("/")
                    if originalIndex < cursorPosition {
                        newCursorPosition += 1
                    }
                }
                groomed.append(char)
                digitCount += 1
            }

            originalIndex += 1
            if groomed.count == 5 { break } // "MM/YY"
        }

        newCursorPosition = min(newCursorPosition, groomed.count)
        return (formattedText: groomed, newCursorPosition: newCursorPosition)
    }

    func formatSecurityCode(updatedText: String) -> String {
        var groomed = ""
        for char in updatedText {
            if char.isASCII && char.isNumber {
                groomed.append(char)
            }
        }
        return groomed
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
