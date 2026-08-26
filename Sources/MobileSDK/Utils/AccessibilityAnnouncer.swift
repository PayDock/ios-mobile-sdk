//
//  AccessibilityAnnouncer.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import UIKit

/// Central helper for posting VoiceOver announcements so every widget speaks
/// validation feedback the same way (matching the CardDetails widget's behaviour).
enum AccessibilityAnnouncer {

    /// Priority of a spoken announcement.
    /// - `interrupting`: cuts off whatever VoiceOver is currently saying (use for errors).
    /// - `queued`: waits for the current utterance to finish (use for summaries/counts).
    enum Priority {
        case interrupting
        case queued
    }

    /// Announces a field error, prefixed with "Error: ", interrupting current speech so the
    /// user hears the problem immediately even if focus has moved on.
    static func announceFieldError(_ message: String) {
        post("Error: \(message)", priority: .interrupting)
    }

    /// The VoiceOver summary spoken after a failed submit. Returns `nil` when there are no errors.
    static func errorCountMessage(_ count: Int) -> String? {
        switch count {
        case ..<1: return nil
        case 1: return "There is 1 error in form"
        default: return "There are \(count) errors in form"
        }
    }

    /// Posts an announcement to VoiceOver at the given priority.
    static func post(_ message: String, priority: Priority) {
        guard !message.isEmpty else { return }

        if #available(iOS 17.0, *) {
            var attributed = AttributedString(message)
            attributed.accessibilitySpeechAnnouncementPriority = priority == .interrupting ? .high : .default
            AccessibilityNotification.Announcement(attributed).post()
        } else {
            // Pre-iOS 17 has no priority control; post the raw announcement.
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}

extension View {

    /// Announces the bound field error via VoiceOver whenever it transitions to a non-empty value,
    /// so the error is spoken immediately even if focus has already moved to another field.
    /// Pass `suppressed: true` during a batch submit so the per-field errors don't drown out the
    /// aggregate "N errors in form" announcement.
    func announceError(_ error: Binding<String>, suppressed: Bool = false) -> some View {
        onChange(of: error.wrappedValue) { newValue in
            if !newValue.isEmpty && !suppressed {
                AccessibilityAnnouncer.announceFieldError(newValue)
            }
        }
    }
}
