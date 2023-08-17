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

}
