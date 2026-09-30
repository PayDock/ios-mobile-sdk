//
//  Standalone3DSProgress.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Intermediate progress of a Standalone 3DS authentication, delivered through the optional
/// `onProgress` callback of ``Standalone3DSWidget``.
///
/// These are not final outcomes — the final result is always delivered through the widget's `completion`.
/// Typical order: challenge flow `challengeStarted` → `challengeLoaded` → `challengeCompleted` → final event;
/// decoupled flow `decoupled` → `challengeCompleted` → final event; frictionless flows emit no progress.
///
/// New cases may be added in future minor versions as the 3DS flow gains steps — include a `default`
/// case when switching over it.
public enum Standalone3DSProgress: Equatable {
    /// The issuer requires a challenge. The bank's challenge page is still loading — keep any loader visible.
    case challengeStarted(charge3dsId: String?)
    /// The bank's challenge page has loaded (or the 2.5 s fallback elapsed) and is visible to the shopper.
    /// Emitted once per challenge; never for decoupled authentications.
    case challengeLoaded(charge3dsId: String?, reason: ChallengeLoadedReason)
    /// The shopper finished the challenge (or approved a decoupled authentication) and the result is being confirmed.
    /// Emitted at most once, always before the final event. A wrong OTP does not emit it.
    case challengeCompleted(charge3dsId: String?, source: ChallengeCompletedSource)
    /// The authentication must be approved out-of-band (e.g. in the shopper's banking app).
    /// `description` is shopper-facing copy from the issuer and should be displayed when present.
    case decoupled(charge3dsId: String?, description: String?)

    /// Why ``Standalone3DSProgress/challengeLoaded(charge3dsId:reason:)`` was emitted. Informational only.
    public enum ChallengeLoadedReason: String {
        /// The challenge page finished loading.
        case load
        /// No load was observed within 2.5 s; emitted anyway so a loader is never held forever.
        case timeout
        /// A value not known to this SDK version.
        case unknown
    }

    /// How completion of the challenge was detected. Informational only — handle both the same way.
    public enum ChallengeCompletedSource: String {
        /// The 3DS server's result monitor reported it (the usual case).
        case poll
        /// The callback carrying the outcome arrived first.
        case callback
        /// A value not known to this SDK version.
        case unknown
    }
}
