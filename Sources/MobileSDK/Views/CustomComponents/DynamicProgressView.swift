//
//  DynamicProgressView.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

class DynamicProgressView: UIView {

    // Configuration Properties
    var appearance: Theme.OverlayLoaderAppearance {
        didSet { applyAppearance() }
    }

    // Derived Properties (computed from appearance)
    private var loaderType: OverlayLoaderType { appearance.loaderType }
    private var loadingText: String { appearance.loaderText }
    private var cardBackgroundColor: UIColor { UIColor(appearance.cardAppearance.color) }
    private var overlayBackgroundColor: UIColor { UIColor(appearance.backgroundColor) }
    private var cardCornerRadius: CGFloat { appearance.cardAppearance.cornerRadius }
    private var cardPadding: UIEdgeInsets { appearance.cardAppearance.padding }
    private var loaderColor: UIColor { UIColor(appearance.loaderAppearance.color) }
    private var textColor: UIColor { UIColor(appearance.loaderTextAppearance.text.textColor) }

    /// Spinner size scaled by the current Dynamic Type setting so the loader grows alongside
    /// the label when the user bumps text size in Settings → Accessibility.
    private var loaderSize: CGSize {
        let metrics = UIFontMetrics.default
        return CGSize(
            width: metrics.scaledValue(for: appearance.loaderSize.width),
            height: metrics.scaledValue(for: appearance.loaderSize.height)
        )
    }

    /// Gap between spinner and text, scaled with Dynamic Type so the layout breathes
    /// proportionally at larger sizes.
    private var spacing: CGFloat {
        UIFontMetrics.default.scaledValue(for: appearance.loaderSpacing)
    }

    /// Ratio between the scaled spinner size and the configured base size. Applied as a
    /// transform to the UIActivityIndicatorView (whose drawn pattern is otherwise fixed by
    /// its style) so the UIKit-style loader also grows with Dynamic Type.
    private var loaderScaleFactor: CGFloat {
        let baseDim = max(appearance.loaderSize.width, appearance.loaderSize.height)
        let scaledDim = max(loaderSize.width, loaderSize.height)
        return baseDim > 0 ? scaledDim / baseDim : 1.0
    }

    // UI Elements
    private let cardView = UIView()
    private let shapeLayer = CAShapeLayer()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let label = UILabel()
    private let announcementManager = LoadingAnnouncementManager()

    init(frame: CGRect = .zero, appearance: Theme.OverlayLoaderAppearance) {
        self.appearance = appearance
        super.init(frame: frame)
        setupView()
        applyAppearance()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        // Card Setup
        cardView.clipsToBounds = true
        addSubview(cardView)

        // Spinner (Custom) - will be reparented based on showCard
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0.3

        // Label - will be reparented based on showCard
        label.textAlignment = .center
        // Re-scale automatically when the user changes text size or Bold Text at runtime.
        label.adjustsFontForContentSizeCategory = true
        // Wrap onto multiple lines instead of truncating when accessibility font sizes push
        // the loader text past the configured wrap width.
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
    }

    private func applyAppearance() {
        // Apply overlay background
        self.backgroundColor = overlayBackgroundColor

        // Apply loader color
        shapeLayer.strokeColor = loaderColor.cgColor
        activityIndicator.color = loaderColor

        // Apply text appearance
        label.textColor = textColor
        label.text = loadingText

        // Apply font from TextAttributes
        label.font = uiFontFromCustomFont(appearance.loaderTextAppearance.text.customFont)

        // Reparent views based on showCard
        updateViewHierarchy()

        applyAccessibility()

        setNeedsLayout()
    }

    private func applyAccessibility() {
        isAccessibilityElement = true
        // Fall back to the visible loader text, but strip trailing ellipsis characters first —
        // VoiceOver pronounces "..." (and the U+2026 single-glyph ellipsis) as "ellipsis",
        // which reads awkwardly after the loader label (e.g. "Processing payment ellipsis").
        // Consumers can override entirely via `appearance.accessibilityLabel`.
        accessibilityLabel = appearance.accessibilityLabel ?? voiceOverLabel(for: appearance.loaderText)
        accessibilityHint = appearance.accessibilityHint
        accessibilityIdentifier = appearance.accessibilityIdentifier
        accessibilityTraits = [.updatesFrequently]
        accessibilityViewIsModal = true
    }

    private func voiceOverLabel(for text: String) -> String {
        var trimmed = text
        while trimmed.hasSuffix("...") {
            trimmed = String(trimmed.dropLast(3))
        }
        while trimmed.hasSuffix("\u{2026}") {
            trimmed = String(trimmed.dropLast())
        }
        return trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateViewHierarchy() {
        // Remove views from current parents
        activityIndicator.removeFromSuperview()
        label.removeFromSuperview()
        shapeLayer.removeFromSuperlayer()

        if appearance.showCard {
            // Add to card view
            cardView.isHidden = false
            cardView.layer.addSublayer(shapeLayer)
            cardView.addSubview(activityIndicator)
            cardView.addSubview(label)
        } else {
            // Add directly to base view
            cardView.isHidden = true
            self.layer.addSublayer(shapeLayer)
            self.addSubview(activityIndicator)
            self.addSubview(label)
        }
    }

    private func uiFontFromCustomFont(_ customFont: CustomFont) -> UIFont {
        let size = customFont.size

        switch customFont.type {
        case .system:
            // Use the system font so the Accessibility "Bold Text" toggle applies (custom-named
            // fonts don't have automatic weight variants). Then scale via UIFontMetrics so
            // Dynamic Type (font-size accessibility setting) is honoured too.
            let weight: UIFont.Weight = UIAccessibility.isBoldTextEnabled ? .bold : .regular
            let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
            return UIFontMetrics.default.scaledFont(for: baseFont)

        case .custom(let name):
            // Custom fonts: scale with Dynamic Type. Bold Text doesn't auto-apply to custom
            // fonts (they have whatever weight the asset ships with).
            let baseFont = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
            return UIFontMetrics.default.scaledFont(for: baseFont)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let spinnerSize = max(loaderSize.width, loaderSize.height)

        if appearance.showCard {
            // Layout with card
            layoutWithCard(spinnerSize: spinnerSize)
        } else {
            // Layout without card (centered in main view)
            layoutWithoutCard(spinnerSize: spinnerSize)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Re-run layoutSubviews when the user changes Dynamic Type while the loader is on
        // screen — `loaderSize`, `spacing`, the text bounding rect, and the activity
        // indicator transform all read from the current content size category.
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setNeedsLayout()
        }
    }

    // swiftlint:disable:next function_body_length
    private func layoutWithCard(spinnerSize: CGFloat) {
        let horizontalPadding = cardPadding.left + cardPadding.right
        let verticalPadding = cardPadding.top + cardPadding.bottom

        // Wrap width grows with the available horizontal room so landscape + large accessibility
        // sizes don't force the text into many tall lines (which previously pushed the card
        // beyond the screen height). Clamped to [200, 400] so we keep the original portrait
        // wrap behaviour and don't grow absurdly wide on iPad.
        let edgeMargin: CGFloat = 32
        let availableWrapWidth = bounds.width - (edgeMargin * 2) - horizontalPadding
        let maxTextWidth: CGFloat = max(200, min(availableWrapWidth, 400))
        let textSize = (loadingText as NSString).boundingRect(
            with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: label.font as Any],
            context: nil
        ).size

        // Calculate card size dynamically if not specified
        let cardSize: CGSize
        if let explicitSize = appearance.cardAppearance.size {
            cardSize = explicitSize
        } else {
            let rawContentWidth = max(spinnerSize, textSize.width) + horizontalPadding
            let rawContentHeight = spinnerSize + spacing + textSize.height + verticalPadding
            // Defensive cap: never grow the card past the visible bounds (minus an edge margin).
            // Matters in landscape with the largest accessibility sizes — otherwise the spinner
            // ends up off-screen.
            let maxCardWidth = max(bounds.width - edgeMargin * 2, 0)
            let maxCardHeight = max(bounds.height - edgeMargin * 2, 0)
            cardSize = CGSize(
                width: min(rawContentWidth, maxCardWidth),
                height: min(rawContentHeight, maxCardHeight)
            )
        }

        // Position Card in the center
        cardView.frame = CGRect(
            x: (bounds.width - cardSize.width) / 2,
            y: (bounds.height - cardSize.height) / 2,
            width: cardSize.width,
            height: cardSize.height
        )
        cardView.backgroundColor = cardBackgroundColor
        cardView.layer.cornerRadius = cardCornerRadius

        let contentHeight = spinnerSize + spacing + textSize.height
        let startY = cardPadding.top + (cardSize.height - cardPadding.top - cardPadding.bottom - contentHeight) / 2

        // Position Custom Spinner (relative to card)
        let spinnerRect = CGRect(x: (cardSize.width - spinnerSize) / 2, y: startY, width: spinnerSize, height: spinnerSize)
        shapeLayer.frame = spinnerRect
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: spinnerSize/2, y: spinnerSize/2),
            radius: (spinnerSize - 4)/2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        shapeLayer.path = circularPath.cgPath

        // Position UIKit Spinner (relative to card). UIActivityIndicatorView's drawn pattern
        // is sized by its style (e.g. `.large`), not its frame, so apply a scale transform to
        // keep it visually proportional to the configured loader size at the current
        // Dynamic Type setting.
        activityIndicator.frame = spinnerRect
        activityIndicator.transform = CGAffineTransform(scaleX: loaderScaleFactor, y: loaderScaleFactor)

        // Position Label (relative to card)
        let labelWidth = cardSize.width - cardPadding.left - cardPadding.right
        label.frame = CGRect(
            x: cardPadding.left,
            y: spinnerRect.maxY + spacing,
            width: labelWidth,
            height: textSize.height
        )
    }

    private func layoutWithoutCard(spinnerSize: CGFloat) {
        // Wrap width grows with available bounds for the same reason as the card layout —
        // keeps landscape + large accessibility sizes within the visible area.
        let edgeMargin: CGFloat = 32
        let availableWrapWidth = bounds.width - (edgeMargin * 2)
        let maxTextWidth: CGFloat = max(200, min(availableWrapWidth, 400))
        let textSize = (loadingText as NSString).boundingRect(
            with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: label.font as Any],
            context: nil
        ).size

        // Calculate total content height
        let contentHeight = spinnerSize + spacing + textSize.height
        let startY = (bounds.height - contentHeight) / 2

        // Position Custom Spinner (centered in main view)
        let spinnerX = (bounds.width - spinnerSize) / 2
        let spinnerRect = CGRect(x: spinnerX, y: startY, width: spinnerSize, height: spinnerSize)
        shapeLayer.frame = spinnerRect
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: spinnerSize/2, y: spinnerSize/2),
            radius: (spinnerSize - 4)/2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        shapeLayer.path = circularPath.cgPath

        // Position UIKit Spinner (centered in main view). Apply scale transform so the drawn
        // pattern keeps proportion with the configured loader size at the current Dynamic
        // Type setting (see comment in layoutWithCard).
        activityIndicator.frame = spinnerRect
        activityIndicator.transform = CGAffineTransform(scaleX: loaderScaleFactor, y: loaderScaleFactor)

        // Position Label (centered below spinner)
        let labelWidth = min(textSize.width, maxTextWidth)
        label.frame = CGRect(
            x: (bounds.width - labelWidth) / 2,
            y: spinnerRect.maxY + spacing,
            width: labelWidth,
            height: textSize.height
        )
    }

    func startAnimating() {
        self.isHidden = false
        shapeLayer.isHidden = (loaderType != .swiftUIStyle)
        activityIndicator.isHidden = (loaderType != .uiKitActivityIndicator)

        if loaderType == .swiftUIStyle {
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 1.2
            rotation.repeatCount = .infinity
            shapeLayer.add(rotation, forKey: "rotation")

            let stroke = CABasicAnimation(keyPath: "strokeEnd")
            stroke.fromValue = 0.05
            stroke.toValue = 0.95
            stroke.duration = 0.8
            stroke.autoreverses = true
            stroke.repeatCount = .infinity
            shapeLayer.add(stroke, forKey: "stroke")
        } else {
            activityIndicator.startAnimating()
        }

        DispatchQueue.main.async {
            UIAccessibility.post(notification: .screenChanged, argument: self)
        }
        announcementManager.start()
    }

    func stopAnimating() {
        self.isHidden = true
        shapeLayer.removeAllAnimations()
        activityIndicator.stopAnimating()
        announcementManager.stop()
    }
}
