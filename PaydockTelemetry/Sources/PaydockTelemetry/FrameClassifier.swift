//
//  FrameClassifier.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Decides whether a crash's frames are the SDK's (spec § 7.2) from the saved ranges of the last builds, never from
/// symbols, so a stripped build classifies the same as an unstripped one.
package struct FrameClassifier: Sendable, Equatable {
    package enum Verdict: Sendable, Equatable { case sdk, notSdk, unknown }

    package let builds: [FramePoints]              // current build first, at most TelemetryLimits.frameBuildsKept

    package init(builds: [FramePoints]) {
        self.builds = Array(builds.prefix(TelemetryLimits.frameBuildsKept))
    }

    /// UUID with saved ranges → sdk or notSdk by the ranges; else the name of a saved build's image → unknown;
    /// else notSdk.
    package func classify(_ frame: FrameAddress) -> Verdict {
        if let uuid = frame.uuid, let build = builds.first(where: { $0.uuid == uuid }) {
            return build.contains(frame.offset) ? .sdk : .notSdk
        }
        if builds.contains(where: { $0.imageName == frame.imageName }) {
            return .unknown
        }
        return .notSdk
    }

    /// No frames → nil; any sdk → true; any unknown → nil; else false.
    package func inSdk(_ frames: [FrameAddress]) -> Bool? {
        guard !frames.isEmpty else {
            return nil
        }
        let verdicts = frames.map(classify)
        if verdicts.contains(.sdk) {
            return true
        }
        if verdicts.contains(.unknown) {
            return nil
        }
        return false
    }

    /// The current build first, then the saved ones with another UUID, at most frameBuildsKept.
    package static func merging(current: FramePoints, saved: [FramePoints]) -> [FramePoints] {
        var builds = [current]
        for build in saved where !builds.contains(where: { $0.uuid == build.uuid }) {
            builds.append(build)
        }
        return Array(builds.prefix(TelemetryLimits.frameBuildsKept))
    }
}
