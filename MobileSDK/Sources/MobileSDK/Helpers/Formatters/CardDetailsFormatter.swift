//
//  CardExpiryDateFormatter.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 17.08.2023..
//

import Foundation

class CardDetailsFormatter {

    func formatCardNumber(updatedText: String) -> String {
        var groomed = ""
        for c in updatedText {
            if c == " " && (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19)  {
                groomed.append(c)
            } else if c.isASCII && c.isNumber {
                if (groomed.count == 4 || groomed.count == 9 || groomed.count == 14 || groomed.count == 19) {
                    groomed.append(" ")
                }
                groomed.append(c)
            }
            if groomed.count == 24 {
                break
            }
        }
        return groomed
    }

    func formatExpiryDate(updatedText: String) -> String {
        var groomed = ""
        for c in updatedText {
            if c == "/" && groomed.count == 2  {
                groomed.append(c)
            } else if c.isASCII && c.isNumber {
                if groomed.count == 2 {
                    groomed.append("/")
                }
                groomed.append(c)
            }
            if groomed.count == 5 {
                break
            }
        }
        return groomed
    }

}
