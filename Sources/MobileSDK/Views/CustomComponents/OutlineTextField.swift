//
//  OutlineTextField.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import UIKit

struct OutlineTextField: View {

    @Environment(\.dynamicTypeSize) var sizeCategory
    @ScaledMetric private var rightIconSize: CGFloat = 20
    @ScaledMetric private var leftIconWidth: CGFloat = 28
    @ScaledMetric private var leftIconHeight: CGFloat = 24

    // MARK: Properties

    private let appearance: Theme.TextFieldAppearance

    @State private var borderColor = Color.clear
    @State private var borderWidth: CGFloat = 0.0

    @State private var titleBackgroundOpacity = 0.0
    @State private var titleColor = Color.clear
    @State private var titleFontSize = 0.0
    @State private var animatableEditingState = false
    @State private var showPlaceholder = false

    private var titleLeadingPadding: Double {
        let isActive = animatableEditingState || !text.isEmpty
        if isActive {
            return 14.0
        } else {
            return (leftImage != nil) ? (leftIconWidth + 24) : 14.0
        }
    }

    private var titleBottomPadding: Double {
        let isActive = animatableEditingState || !text.isEmpty
        if isActive {
            return 48.0 + getTitleExtraPadding()
        } else {
            return 0.0
        }
    }

    private var titleVerticalPadding: CGFloat {
        let isActive = animatableEditingState || !text.isEmpty
        if isActive {
            return -11.0
        } else {
            return 0.0
        }
    }

    private var effectivePlaceholder: String {
        // Only show placeholder when editing, text field is empty, and animation has completed
        return (showPlaceholder && text.isEmpty) ? appearance.placeholderText ?? "" : ""
    }

    @State private var validationIconState: ValidationIconState = .none

    @State private var errorViewOpacity: Double = 0
    @State private var errorViewScale = 0
    @State private var showErrorView = false

    @Binding private var text: String
    @Binding private var valid: Bool?
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String
    private var accessibilityValue: String?
    private let spellOutValue: Bool
    @Binding private var disabled: Bool
    @Binding private var leftImageAccessibilityLabel: String?

    private let title: String
    private let validationIconEnabled: Bool
    private let textContentType: UITextContentType?
    private let returnKeyType: UIReturnKeyType
    private let isSecureTextEntry: Bool
    private let autocorrectionDisabled: Bool
    private let onTapGesture: () -> Void
    private let onTextChange: ((String, Int) -> Int)?
    private let onSubmit: (() -> Void)?
    private let fieldAccessibilityIdentifier: String?
    private let keyboardType: UIKeyboardType

    // MARK: - Initialization

    /// Creates a Material Design inspired text field with an animated border and title.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - title: The title string.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    ///   - disabled: Whether the field is in a disabled state.
    ///   - validationIconEnabled: Whether to enabled the validation icon.
    ///   - textContentType: Content type used for the suggested prefill.
    ///   - keyboardType: Keyboard type for the text field.
    ///   - returnKeyType: Return key type for the text field.
    ///   - isSecureTextEntry: Whether to mask input (for sensitive data like CVV).
    ///   - autocorrectionDisabled: Whether to disable autocorrection and spell checking.
    ///   - onTapGesture: Action to take on tap gesture activaction.
    ///   - onTextChange: Custom text change handler that returns new cursor position.
    ///   - onSubmit: Action to take when return key is pressed.
    public init(appearance: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
                text: Binding<String>,
                title: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool?>,
                disabled: Binding<Bool>,
                validationIconEnabled: Bool = true,
                textContentType: UITextContentType? = nil,
                keyboardType: UIKeyboardType = .default,
                returnKeyType: UIReturnKeyType = .default,
                isSecureTextEntry: Bool = false,
                autocorrectionDisabled: Bool = false,
                accessibilityValue: String? = nil,
                spellOutValue: Bool = false,
                leftImageAccessibilityLabel: Binding<String?>? = nil,
                accessibilityIdentifier: String? = nil,
                onTapGesture: @escaping (() -> Void),
                onTextChange: ((String, Int) -> Int)? = nil,
                onSubmit: (() -> Void)? = nil) {
        self.appearance = appearance
        self._text = text
        self.title = title
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._disabled = disabled
        self.validationIconEnabled = validationIconEnabled
        self.textContentType = textContentType
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.isSecureTextEntry = isSecureTextEntry
        self.autocorrectionDisabled = autocorrectionDisabled
        self.accessibilityValue = accessibilityValue
        self.spellOutValue = spellOutValue
        self._leftImageAccessibilityLabel = leftImageAccessibilityLabel ?? .constant(nil)
        self.onTapGesture = onTapGesture
        self.onTextChange = onTextChange
        self.onSubmit = onSubmit
        self.fieldAccessibilityIdentifier = accessibilityIdentifier
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack {
            ZStack {
                textFieldView
                placeholderView()
                    .accessibilityHidden(true)
            }
            if showErrorView {
                errorView()
                    .accessibilityHidden(true)
            } else if !(appearance.hintText ?? "").isEmpty {
                hintView()
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .padding(appearance.dimensions.padding)
        .onTapGesture {
            onTapGesture()
        }
        .onChange(of: editing) { newValue in
            withAnimation(.easeOut(duration: 0.15)) {
                animatableEditingState = editing
                updateBorder()
                updateTitle()
            }

            // Delay placeholder appearance to sync with title animation
            if newValue {
                // Show placeholder after animation completes (0.15s + small buffer)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showPlaceholder = true
                }
            } else {
                // Hide placeholder immediately when editing ends
                showPlaceholder = false
            }
        }
        .onChange(of: valid) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                updateBorder()
                updateTitle()
            }
        }
        .onChange(of: errorMessage) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                showErrorView = !errorMessage.isEmpty
                updateBorder()
            }
        }
        .onChange(of: text) { _ in
            updateTitle()
        }
        .onChange(of: leftImageAccessibilityLabel) { newValue in
            // Announce the detected card scheme once (e.g. "Visa") as it's recognised, mirroring
            // Android. Fires on the change to a non-empty scheme, not per keystroke.
            if let scheme = newValue, !scheme.isEmpty {
                UIAccessibility.post(notification: .announcement, argument: scheme)
            }
        }
        .onChange(of: sizeCategory) { _ in
            updateTitleFontSize()
        }
        .onAppear {
            titleColor = appearance.colors.hint
            titleFontSize = appearance.fonts.title.customFont.size
            borderColor = appearance.colors.inactive
            borderWidth = appearance.dimensions.borderWidth
        }
    }

    private var textFieldView: some View {
        HStack {
            leftImage?
                .resizable()
                .scaledToFit()
                .frame(width: leftIconWidth, height: leftIconHeight)
                .foregroundColor(appearance.colors.icon)
                .accessibilityHidden(true)

            CursorPositionTextField(
                text: $text,
                placeholder: effectivePlaceholder,
                keyboardType: keyboardType,
                textContentType: textContentType,
                returnKeyType: returnKeyType,
                font: UIFont.init(descriptor: appearance.fonts.text.customFont.fontDescriptor, size: appearance.fonts.text.customFont.size),
                textColor: UIColor(appearance.colors.text),
                tintColor: UIColor(appearance.colors.active),
                isUnderlined: appearance.fonts.text.isUnderlined,
                underlineColor: UIColor(appearance.fonts.text.underlineColor),
                isStrikethrough: appearance.fonts.text.isStrikethrough,
                strikethroughColor: UIColor(appearance.fonts.text.strikethroughColor),
                isItalic: appearance.fonts.text.isItalic,
                placeholderFont: UIFont(descriptor: appearance.fonts.placeholder.customFont.fontDescriptor,
                                        size: appearance.fonts.placeholder.customFont.size),
                placeholderColor: UIColor(appearance.colors.placeholder),
                placeholderIsUnderlined: appearance.fonts.placeholder.isUnderlined,
                placeholderUnderlineColor: UIColor(appearance.fonts.placeholder.underlineColor),
                placeholderIsStrikethrough: appearance.fonts.placeholder.isStrikethrough,
                placeholderStrikethroughColor: UIColor(appearance.fonts.placeholder.strikethroughColor),
                placeholderIsItalic: appearance.fonts.placeholder.isItalic,
                isSecureTextEntry: isSecureTextEntry,
                autocorrectionDisabled: autocorrectionDisabled,
                accessibilityLabel: title,
                accessibilityIdentifier: fieldAccessibilityIdentifier,
                onEditingChanged: { isEditing in
                    editing = isEditing
                },
                onCommit: {},
                onSubmit: onSubmit,
                onTextChange: onTextChange
            )
            .simultaneousGesture(TapGesture().onEnded({ _ in
                onTapGesture()
            }))
            .frame(height: getTextFieldHeight())
            .frame(maxWidth: .infinity)
            .layoutPriority(0)
            .disabled(disabled)
            .accessibilityLabel(title)
            .accessibilityValue(spellOutValue
                ? Text(accessibilityValue ?? text).speechSpellsOutCharacters()
                : Text(accessibilityValue ?? text))
            .accessibilityHint(getAccessibilityHint())
            .accessibilityAddTraits(getAccessibilityTraits())

            if validationIconEnabled {
                validationIconView
                    .accessibilityHidden(true)
            }
        }
        .padding([.leading, .trailing], 16.0)
        .background(RoundedRectangle(cornerRadius: appearance.dimensions.cornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: borderWidth))
    }

    private func placeholderView() -> some View {
        HStack {
            ZStack {
                appearance.colors.background
                    .opacity(titleBackgroundOpacity)
                Text(title)
                    .foregroundColor(.white)
                    .colorMultiply(titleColor)
                    .strikethrough(appearance.fonts.title.isStrikethrough, color: appearance.fonts.title.strikethroughColor)
                    .underline(appearance.fonts.title.isUnderlined, color: appearance.fonts.title.underlineColor)
                    .italic(appearance.fonts.title.isItalic)
                    .animatableFont(size: titleFontSize, fontName: appearance.fonts.title.customFont.fontName)
                    .padding([.leading, .trailing], 4.0)
                    .layoutPriority(1)
            }
            .padding([.leading], titleLeadingPadding)
            .padding([.bottom], titleBottomPadding)
            Spacer()
        }
        .padding(.vertical, titleVerticalPadding)
    }

    private func errorView() -> some View {
        Text(errorMessage)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(appearance.fonts.error.customFont.scaledFont)
            .foregroundColor(appearance.colors.error)
            .padding(appearance.dimensions.messagePadding)
            .transition(.opacity) // Smooth transition when appearing/disappearing
    }

    private func hintView() -> some View {
        Text(appearance.hintText ?? "")
            .strikethrough(appearance.fonts.hint.isStrikethrough, color: appearance.fonts.hint.strikethroughColor)
            .underline(appearance.fonts.hint.isUnderlined, color: appearance.fonts.hint.underlineColor)
            .italic(appearance.fonts.hint.isItalic)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(appearance.fonts.hint.customFont.scaledFont)
            .foregroundColor(appearance.colors.hint)
            .padding(appearance.dimensions.messagePadding)
            .transition(.opacity) // Smooth transition when appearing/disappearing
    }

    private var validationIconView: some View {
        HStack {
            switch validationIconState {
            case .valid:
                Image("tick-circle", bundle: Bundle.module)
                    .resizable()
                    .frame(width: rightIconSize, height: rightIconSize)
                    .foregroundColor(appearance.colors.success)

            case .invalid:
                Image("exclamation-circle", bundle: Bundle.module)
                    .resizable()
                    .frame(width: rightIconSize, height: rightIconSize)
                    .foregroundColor(appearance.colors.error)
            case .none: EmptyView()
            }
        }
    }
}

// MARK: - Private methods

private extension OutlineTextField {

    func updateBorder() {
        updateBorderColor()
        updateBorderWidth()
    }

    func updateBorderColor() {
        guard let valid = valid else {
            borderColor = editing ? appearance.colors.active : appearance.colors.inactive
            validationIconState = .none
            return
        }
        if !valid {
            borderColor = appearance.colors.error
            validationIconState = .invalid
        } else if editing {
            borderColor = appearance.colors.active
            validationIconState = .none
        } else {
            borderColor = appearance.colors.placeholder
            validationIconState = text.isEmpty ? .none : .valid
        }
    }

    func updateBorderWidth() {
        borderWidth = editing ? appearance.dimensions.activeBorderWidth : appearance.dimensions.borderWidth
    }

    func updateTitle() {
        updateTitleBackground()
        updateTitleColor()
        updateTitleFontSize()
    }

    func updateTitleBackground() {
        if editing || !text.isEmpty {
            titleBackgroundOpacity = 1.0
        } else {
            titleBackgroundOpacity = 0.0
        }
    }

    func updateTitleColor() {
        guard let valid = valid else {
            titleColor = editing ? appearance.colors.active : appearance.colors.hint
            return
        }
        if valid {
            titleColor = editing ? appearance.colors.active : appearance.colors.hint
        } else if text.isEmpty {
            titleColor = editing ? appearance.colors.error : appearance.colors.hint
        } else {
            titleColor = appearance.colors.error
        }
    }

    func updateTitleFontSize() {
        if editing || !text.isEmpty {
            titleFontSize = appearance.fonts.title.customFont.size / 1.4
        } else {
            titleFontSize = appearance.fonts.title.customFont.size
        }
    }

    enum ValidationIconState {
        case valid
        case invalid
        case none
    }
}

// MARK: - Accessibility handling

extension OutlineTextField {

    private func getTextFieldHeight() -> CGFloat {
        switch sizeCategory {
        case .xSmall: return 38
        case .small: return 42
        case .medium: return 44
        case .large: return 50
        case .xLarge: return 54
        case .xxLarge: return 58
        case .xxxLarge: return 62

        case .accessibility1: return 70
        case .accessibility2: return 100
        case .accessibility3: return 130
        case .accessibility4: return 160
        case .accessibility5: return 190
        @unknown default: return 48
        }
    }

    private func getTitleExtraPadding() -> CGFloat {
        switch sizeCategory {
        case .xSmall: return -8.0
        case .small: return -4.0
        case .medium: return 0.0
        case .large: return 4.0
        case .xLarge: return 8.0
        case .xxLarge: return 12.0
        case .xxxLarge: return 16.0

        case .accessibility1: return 22.0
        case .accessibility2: return 52.0
        case .accessibility3: return 82.0
        case .accessibility4: return 112.0
        case .accessibility5: return 142.0
        @unknown default: return 48
        }
    }

    private func getAccessibilityHint() -> String {
        // In error state, only the error message is announced — no hint, no "required",
        // and no contextual extras (card scheme, "Valid", placeholder example). Keeps the
        // VoiceOver readout focused on what the user has to fix.
        if !errorMessage.isEmpty {
            return "Error: \(errorMessage)"
        }

        // Non-error state — build the regular contextual hint.
        var hintComponents: [String] = []

        // A custom accessibility hint overrides ONLY the visual hint text; the placeholder example
        // (and card scheme, "Valid", "required") are still announced. 
        let customHint = appearance.accessibilityHintText?.isEmpty == false
            ? appearance.accessibilityHintText
            : nil

        // Add card scheme information if available
        if let cardScheme = leftImageAccessibilityLabel, !cardScheme.isEmpty {
            hintComponents.append(cardScheme)
        }

        // Add validation status only when the valid icon is actually shown — i.e. not while
        // editing (see updateBorderColor) — so VoiceOver doesn't announce "Valid" before the
        // tick appears on unfocus.
        if validationIconState == .valid {
            hintComponents.append("Valid")
        }

        // Add placeholder information when field is empty. Always announced, regardless of any
        // custom accessibility hint.
        if let placeholderText = appearance.placeholderText, !placeholderText.isEmpty {
            if editing && text.isEmpty {
                hintComponents.append("Example: \(placeholderText)")
            }
        }

        // Use the custom accessibility hint if provided, otherwise fall back to the visual hint.
        if let customHint = customHint {
            hintComponents.append(customHint)
        } else if let hintMessage = appearance.hintText, !hintMessage.isEmpty {
            hintComponents.append(hintMessage)
        }

        // Add required suffix if field is not optional
        let isOptional = title.lowercased().contains("(optional)")
        if !isOptional && !hintComponents.isEmpty {
            hintComponents.append("required")
        }

        return hintComponents.joined(separator: ", ")
    }

    private func getAccessibilityTraits() -> AccessibilityTraits {
        var traits: AccessibilityTraits = []

        // Mark as updated when validation state changes
        if valid != nil, !text.isEmpty {
            _ = traits.insert(.updatesFrequently)
        }

        return traits
    }
}

// MARK: - OutlineTextField_Previews

struct OutlineTextField_Previews: PreviewProvider {

    static var previews: some View {
        OutlineTextField(
            text: .constant("Text"),
            title: "Title",
            errorMessage: .constant("Error message"),
            editing: .constant(false),
            valid: .constant(false),
            disabled: .constant(false),
            onTapGesture: {},
            onSubmit: {}
        )
    }
}
