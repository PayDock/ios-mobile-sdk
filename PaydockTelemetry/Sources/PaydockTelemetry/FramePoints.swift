//
//  FramePoints.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One build's SDK ranges (spec § 7.2). Codable: saved as JSON.
package struct FramePoints: Sendable, Equatable, Codable {
    package static let sdkModules: Set<String> = [
        "MobileSDK", "PaydockTelemetry", "NetworkingLib", "CommonModels", "BinProcessing", "DataGateways",
        "DataPaymentSources", "DataCharges", "DataCustomer", "DataVault", "DataMPGS3ds", "DataStandalone3ds"
    ]

    package let imageName: String
    package let uuid: String                       // uppercase, with dashes
    package let sdkRanges: [ClosedRange<UInt64>]   // ascending, disjoint

    package init(imageName: String, uuid: String, sdkRanges: [ClosedRange<UInt64>]) {
        self.imageName = imageName
        self.uuid = uuid
        self.sdkRanges = sdkRanges
    }

    /// Sorts the points by offset (ties: Paydock first); each maximal run of consecutive Paydock points is one range,
    /// from its first offset to its last. Nil when no point is Paydock.
    package init?(imageName: String, uuid: String, points: [TypePoint]) {
        let sorted = points.map { (offset: $0.offset, isSdk: Self.sdkModules.contains($0.module)) }
            .sorted { lhs, rhs in
                lhs.offset != rhs.offset ? lhs.offset < rhs.offset : (lhs.isSdk && !rhs.isSdk)
            }
        var ranges: [ClosedRange<UInt64>] = []
        var runStart: UInt64?
        var runEnd: UInt64 = 0
        for point in sorted {
            if point.isSdk {
                runStart = runStart ?? point.offset
                runEnd = point.offset
            } else if let start = runStart {
                ranges.append(start...runEnd)
                runStart = nil
            }
        }
        if let start = runStart {
            ranges.append(start...runEnd)
        }
        guard !ranges.isEmpty else {
            return nil
        }
        self.init(imageName: imageName, uuid: uuid, sdkRanges: ranges)
    }

    /// Whether the offset lies in one of the ranges, both ends included.
    package func contains(_ offset: UInt64) -> Bool {
        var lower = 0
        var upper = sdkRanges.count
        while lower < upper {
            let middle = (lower + upper) / 2
            let range = sdkRanges[middle]
            if offset < range.lowerBound {
                upper = middle
            } else if offset > range.upperBound {
                lower = middle + 1
            } else {
                return true
            }
        }
        return false
    }
}
