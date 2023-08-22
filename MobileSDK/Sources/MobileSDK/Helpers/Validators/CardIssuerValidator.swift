//
//  CardIssuerValidator.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 15.08.2023..
//

import Foundation

/**
 A utility object for detecting card issuer based on card numbers
 */
internal class CardIssuerValidator {

    /**
     Constants for the regex patterns and their corresponding card issuers

     - seealso: CardIssuerType.visa - Visa cards begin with a 4 and have 13-16-19-digit
     - seealso: CardIssuerType.mastercard - Mastercard cards begin with a 5 and has 16 digits (51, 52, 53, 54, 55, 222100-272099)
     - seealso: CardIssuerType.amex - American Express cards begin with a 3, followed by a 4 or a 7 has 15 digits
     - seealso: CardIssuerType.diners (Diners Club - Carte Blanche) - is a 14-digit number beginning with 300–305,
     - seealso: CardIssuerType.diners (Diners Club - International) - is a 14-digit number beginning with 36, 38, or
     - seealso: CardIssuerType.diners (Diners Club - USA & Canada) - is a 16-digit number beginning with 54
     - seealso: CardIssuerType.jcb - JCB CCN is a 16-19-digit number beginning with 3528 or 3589.
     - seealso: CardIssuerType.masetro - Every Maestro card number is a 16-digit number has a specifically prefix 50, 56-69
     - seealso: CardIssuerType.discover - Credit Card Number (Discover) is a 16-19-digit number beginning with 6011, 644–649 or 65.
     - seealso: CardIssuerType.unionPay - The China UnionPay credit card numbers begin with 62 or 60 and is a 16-19 digit long number.
     - seealso: CardIssuerType.interPay - INTER_PAY CCN is a 16-digit number beginning with 636.
     - seealso: CardIssuerType.instaPayment - Credit Card Number (InstaPayment) is a 16-digit number beginning with 637, 638, 639.
     - seealso: CardIssuerType.uatp - The UATP credit card numbers start with 1 and is 15 digits long
     */
    private let cardIssuerRegexMap: [NSRegularExpression: CardIssuerType] = [
        try! NSRegularExpression(pattern: "^3[47][0-9]{13}$") : .amex,
        try! NSRegularExpression(pattern: "^3(?:0[0-59]|[689])[0-9]*$") : .diners,
        try! NSRegularExpression(pattern: "^4[0-9]*$") : .visa,
        try! NSRegularExpression(pattern: "^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)[0-9]*$") : .mastercard,
        try! NSRegularExpression(pattern: "^6(?:011|5[0-9]{2})[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4,7}$") : .discover,
        try! NSRegularExpression(pattern: "^62[0-9]*$") : .unionPay,
        try! NSRegularExpression(pattern: "^636[0-9]*$") : .interPay,
        try! NSRegularExpression(pattern: "^63[7-9][0-9]*$") : .instaPayment,
        try! NSRegularExpression(pattern: "^(?:2131|1800|35)[0-9]*$") : .jcb,
        try! NSRegularExpression(pattern: "^(5[06789]|6)[0-9]{11,18}$") : .maestro,
        try! NSRegularExpression(pattern: "^1[0-9]*$") : .uatp,
        // The generic pattern for all other card issuers
        try! NSRegularExpression(pattern: ".*") : .other
    ]

    /**
     Detects the card issuer based on the provided credit card number using regex patterns.

     - parameter number: The credit card number to detect the issuer for.
     - returns: The `CardIssuerType` enum representing the detected card issuer, or `CardIssuerType.other` if no issuer is matched.
     */
    func detectCardIssuer(number: String) -> CardIssuerType {
        let cleanNumber = number.filter { !$0.isWhitespace }
        for (regex, issuer) in cardIssuerRegexMap {
            if let _ = regex.firstMatch(in: cleanNumber, options: [], range: NSRange(location: 0, length: cleanNumber.utf16.count)) {
                return issuer
            }
        }
        return .other
    }

}
