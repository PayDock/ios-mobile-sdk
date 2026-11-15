//
//  UtcTimestamp.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// UTC timestamps as text, by integer arithmetic only.
package enum UtcTimestamp {
    private static let millisecondsPerDay: Int64 = 86_400_000

    /// `yyyy-MM-ddTHH:mm:ss.SSSZ` by integer arithmetic only (no calendar, time zone or formatter: UtcOnlyTests).
    package static func iso8601(_ epochMillis: Int64) -> String {
        let days = floorDivide(epochMillis, millisecondsPerDay)
        let millisOfDay = epochMillis &- days &* millisecondsPerDay   // in 0..<millisecondsPerDay, exact modulo 2^64
        let date = civilDate(daysSinceEpoch: days)
        let hours = millisOfDay / 3_600_000
        let minutes = millisOfDay / 60_000 % 60
        let seconds = millisOfDay / 1_000 % 60
        let millis = millisOfDay % 1_000
        return "\(pad(date.year, 4))-\(pad(date.month, 2))-\(pad(date.day, 2))"
            + "T\(pad(hours, 2)):\(pad(minutes, 2)):\(pad(seconds, 2)).\(pad(millis, 3))Z"
    }

    /// Days since 1970-01-01 to a proleptic Gregorian date (the days-to-civil algorithm, eras of 400 years).
    private static func civilDate(daysSinceEpoch: Int64) -> CivilDate {
        let shifted = daysSinceEpoch + 719_468                      // days since 0000-03-01
        let era = floorDivide(shifted, 146_097)
        let dayOfEra = shifted - era * 146_097                       // 0...146_096
        let yearOfEra = (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)   // from March 1
        let monthIndex = (5 * dayOfYear + 2) / 153                   // 0 = March
        let day = dayOfYear - (153 * monthIndex + 2) / 5 + 1
        let month = monthIndex < 10 ? monthIndex + 3 : monthIndex - 9
        let year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0)
        return CivilDate(year: year, month: month, day: day)
    }

    private struct CivilDate {
        let year: Int64
        let month: Int64
        let day: Int64
    }

    /// Floor division for a positive divisor, so a negative value rounds towards minus infinity.
    private static func floorDivide(_ value: Int64, _ divisor: Int64) -> Int64 {
        let quotient = value / divisor
        return value % divisor < 0 ? quotient - 1 : quotient
    }

    private static func pad(_ value: Int64, _ width: Int) -> String {
        let digits = String(value.magnitude)
        let padded = String(repeating: "0", count: max(0, width - digits.count)) + digits
        return value < 0 ? "-" + padded : padded
    }
}
