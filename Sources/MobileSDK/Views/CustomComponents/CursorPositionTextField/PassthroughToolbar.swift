//
//  PassthroughToolbar.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import UIKit

/// A `UIToolbar` that lets touches in its empty (flex-space) area fall through to the view
/// below it. UIKit lays the keyboard's `inputAccessoryView` out at the keyboard's full width,
/// so a toolbar containing `[flexSpace, button]` claims the whole row even though only the
/// right-aligned button is visible. That blocks VoiceOver focus and direct taps on UI sitting
/// beneath the toolbar (e.g. the Submit button when a hardware keyboard is attached or the
/// software keyboard does not fully cover that area).
///
/// `hitTest(_:with:)` here returns `nil` for points where the default implementation only
/// hits the toolbar's own background (no `UIBarButtonItem` was tapped), allowing the touch
/// to fall through. Hits on actual bar button items are unaffected.
final class PassthroughToolbar: UIToolbar {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        // If the only thing under the touch is the toolbar's background, pass through.
        return hitView === self ? nil : hitView
    }
}
