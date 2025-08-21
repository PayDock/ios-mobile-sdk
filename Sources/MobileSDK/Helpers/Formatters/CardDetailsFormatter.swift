//
//  CardExpiryDateFormatter.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardDetailsFormatter {

    func formatCardNumber(updatedText: String) -> String {
        var groomed = ""
        for char in updatedText {
            if char == " " && (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19) {
                groomed.append(char)
            } else if char.isASCII && char.isNumber {
                if groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19 {
                    groomed.append(" ")
                }
                groomed.append(char)
            }
            if groomed.count == 23 {
                break
            }
        }
        return groomed
    }

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

    func formatExpiryDate(updatedText: String) -> String {
        var groomed = ""
        for char in updatedText {
            if char == "/" && groomed.count == 2 {
                groomed.append(char)
            } else if char.isASCII && char.isNumber {
                if groomed.count == 2 {
                    groomed.append("/")
                }
                groomed.append(char)
            }
            if groomed.count == 5 {
                break
            }
        }
        return groomed
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

}
