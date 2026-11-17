//
//  HttpDate.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The HTTP `Date` header (RFC 9110 IMF-fixdate, `Sun, 06 Nov 1994 08:49:37 GMT`) as UTC epoch milliseconds, by integer
/// arithmetic only: no formatter (UtcOnlyTests). Any other form is nil.
package enum HttpDate {
    private static let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    package static func epochMilliseconds(_ value: String) -> Int64? {
        let characters = Array(value)
        guard characters.count == 29,
              dayNames.contains(String(characters[0..<3])),
              String(characters[3..<5]) == ", ",
              characters[7] == " ", characters[11] == " ", characters[16] == " ",
              characters[19] == ":", characters[22] == ":",
              String(characters[25..<29]) == " GMT",
              let day = number(characters[5..<7]),
              let monthIndex = monthNames.firstIndex(of: String(characters[8..<11])),
              let year = number(characters[12..<16]),
              let hour = number(characters[17..<19]),
              let minute = number(characters[20..<22]),
              let second = number(characters[23..<25]) else {
            return nil
        }
        let month = Int64(monthIndex + 1)
        guard day >= 1, day <= daysInMonth(month, year: year), hour <= 23, minute <= 59, second <= 60 else {
            return nil
        }
        let days = daysSinceEpoch(year: year, month: month, day: day)
        return ((days * 24 + hour) * 60 + minute) * 60_000 + second * 1_000
    }

    /// The ASCII digits as a number; nil when any character is not one.
    private static func number(_ digits: ArraySlice<Character>) -> Int64? {
        var result: Int64 = 0
        for character in digits {
            guard character.isASCII, let digit = character.wholeNumberValue else {
                return nil
            }
            result = result * 10 + Int64(digit)
        }
        return result
    }

    private static func daysInMonth(_ month: Int64, year: Int64) -> Int64 {
        switch month {
        case 2:
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    /// Days from 1970-01-01 in the proleptic Gregorian system (the days-from-civil algorithm).
    private static func daysSinceEpoch(year: Int64, month: Int64, day: Int64) -> Int64 {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * (month > 2 ? month - 3 : month + 9) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }
}
