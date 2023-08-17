//
//  CardExpiryDateFormatter.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardDetailsFormatter {

    func formatToExpiryDate(oldText: String, updatedText: String) -> String {
        if oldText.count == 1 && updatedText.count == 2 {
            return "\(updatedText)/"
        } else if oldText.count == 3 && updatedText.count == 2 {
            return "\(updatedText)/"
        } else {
            return updatedText
        }
    }

    func formatCardNumber(updatedText: String) -> String {
        var groomed = ""
        for c in updatedText {
            if c == " " && (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19)  {
                // Copy over the hyphen that was in the correct place.
                groomed.append(c)
            } else if c.isASCII && c.isNumber {
                if (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19) {
                    // Insert a hyphen before the 4th digit.
                    groomed.append(" ")
                }
                // Copy over the digit.
                groomed.append(c)
            }
            if groomed.count == 24 {
                break
            }
        }
        return groomed
    }

}
