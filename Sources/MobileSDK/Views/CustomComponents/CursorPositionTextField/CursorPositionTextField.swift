//
//  CursorPositionTextField.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import UIKit
import SwiftUI

extension EnvironmentValues {
    var toolbarButton: ToolbarButtonInfo? {
        get { self[ToolbarButtonKey.self] }
        set { self[ToolbarButtonKey.self] = newValue }
    }
}

struct CursorPositionTextField: UIViewRepresentable {
    @Environment(\.toolbarButton) private var toolbarButton
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let returnKeyType: UIReturnKeyType
    let baseFont: UIFont?
    let textColor: UIColor?
    let tintColor: UIColor?
    let isUnderlined: Bool
    let underlineColor: UIColor?
    let isStrikethrough: Bool
    let strikethroughColor: UIColor?
    let isItalic: Bool
    let placeholderFont: UIFont?
    let placeholderColor: UIColor?
    let placeholderIsUnderlined: Bool
    let placeholderUnderlineColor: UIColor?
    let placeholderIsStrikethrough: Bool
    let placeholderStrikethroughColor: UIColor?
    let placeholderIsItalic: Bool
    let isSecureTextEntry: Bool
    let autocorrectionDisabled: Bool
    let accessibilityLabelText: String?
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    let onSubmit: (() -> Void)?
    let onTextChange: ((String, Int) -> Int)? // Returns new cursor position

    init(text: Binding<String>,
         placeholder: String = "",
         keyboardType: UIKeyboardType = .default,
         textContentType: UITextContentType? = nil,
         returnKeyType: UIReturnKeyType = .default,
         font: UIFont? = nil,
         textColor: UIColor? = nil,
         tintColor: UIColor? = nil,
         isUnderlined: Bool = false,
         underlineColor: UIColor? = nil,
         isStrikethrough: Bool = false,
         strikethroughColor: UIColor? = nil,
         isItalic: Bool = false,
         placeholderFont: UIFont? = nil,
         placeholderColor: UIColor? = nil,
         placeholderIsUnderlined: Bool = false,
         placeholderUnderlineColor: UIColor? = nil,
         placeholderIsStrikethrough: Bool = false,
         placeholderStrikethroughColor: UIColor? = nil,
         placeholderIsItalic: Bool = false,
         isSecureTextEntry: Bool = false,
         autocorrectionDisabled: Bool = false,
         accessibilityLabel: String? = nil,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         onCommit: @escaping () -> Void = {},
         onSubmit: (() -> Void)? = nil,
         onTextChange: ((String, Int) -> Int)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.returnKeyType = returnKeyType
        self.baseFont = font
        self.textColor = textColor
        self.tintColor = tintColor
        self.isUnderlined = isUnderlined
        self.underlineColor = underlineColor
        self.isStrikethrough = isStrikethrough
        self.strikethroughColor = strikethroughColor
        self.isItalic = isItalic
        self.placeholderFont = placeholderFont
        self.placeholderColor = placeholderColor
        self.placeholderIsUnderlined = placeholderIsUnderlined
        self.placeholderUnderlineColor = placeholderUnderlineColor
        self.placeholderIsStrikethrough = placeholderIsStrikethrough
        self.placeholderStrikethroughColor = placeholderStrikethroughColor
        self.placeholderIsItalic = placeholderIsItalic
        self.isSecureTextEntry = isSecureTextEntry
        self.autocorrectionDisabled = autocorrectionDisabled
        self.accessibilityLabelText = accessibilityLabel
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.onSubmit = onSubmit
        self.onTextChange = onTextChange
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        updatePlaceholderStyling(textField)
        textField.keyboardType = keyboardType
        textField.textContentType = textContentType
        textField.returnKeyType = returnKeyType
        textField.textColor = textColor
        textField.tintColor = tintColor
        // Enable secure text entry for masking sensitive data (e.g., CVV) - PCI DSS compliance
        textField.isSecureTextEntry = isSecureTextEntry

        // Set accessibility label for UI testing
        if let accessibilityLabel = accessibilityLabelText {
            textField.accessibilityLabel = accessibilityLabel
        }

        // Configure accessibility to work properly with Full Keyboard Access
        textField.accessibilityTraits = .none
        textField.isAccessibilityElement = true

        // Disable autocorrection and spell checking if requested (e.g., for name fields)
        if autocorrectionDisabled {
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            // Also disable smart punctuation so a typed apostrophe stays a straight quote (')
            // rather than being substituted with a curly quote (’). Names like "D'Angelo" then
            // validate consistently (and match Android, which inserts a straight apostrophe).
            textField.smartQuotesType = .no
            textField.smartDashesType = .no
            textField.smartInsertDeleteType = .no
        }

        // Prevent the text field from expanding
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidEndEditing), for: .editingDidEnd)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidBeginEditing), for: .editingDidBegin)

        // Set initial font with dynamic type support
        updateFont(textField)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Don't update if the change came from the text field itself
        guard !context.coordinator.isUpdatingFromTextField else { return }

        if uiView.text != text {
            uiView.text = text
            updateTextStyling(uiView)
        }

        // Always refresh the attributed placeholder so style updates (font, color,
        // underline, strikethrough, italic) take effect on subsequent recompositions.
        updatePlaceholderStyling(uiView)

        // Update accessibility label if it changed
        if let accessibilityLabel = accessibilityLabelText {
            uiView.accessibilityLabel = accessibilityLabel
        }

        // Update font when dynamic type size changes
        updateFont(uiView)

        uiView.returnKeyType = returnKeyType

        // Ensure the text field doesn't expand
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Update toolbar based on environment
        if let toolbarInfo = toolbarButton {
            if uiView.inputAccessoryView == nil {
                let toolbar = PassthroughToolbar()
                toolbar.sizeToFit()

                let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let button = UIBarButtonItem(
                    title: toolbarInfo.title,
                    style: .plain,
                    target: context.coordinator,
                    action: #selector(Coordinator.toolbarButtonTapped)
                )

                if let font = toolbarInfo.font {
                    button.setTitleTextAttributes([.font: font], for: .normal)
                }

                if let textColor = toolbarInfo.textColor {
                    button.setTitleTextAttributes([.foregroundColor: textColor], for: .normal)
                }

                toolbar.setItems([flexSpace, button], animated: false)
                uiView.inputAccessoryView = toolbar
            }

            context.coordinator.toolbarAction = toolbarInfo.action
        } else {
            uiView.inputAccessoryView = nil
            context.coordinator.toolbarAction = nil
        }
    }

    private func updatePlaceholderStyling(_ textField: UITextField) {
        // UITextField ignores font/color etc. on the plain `placeholder` string — they only
        // apply via `attributedPlaceholder`. Always build the attributed string so callers'
        // appearance overrides (font, color, underline, strikethrough, italic) actually render.
        guard !placeholder.isEmpty else {
            textField.attributedPlaceholder = nil
            textField.placeholder = nil
            return
        }

        var attributes: [NSAttributedString.Key: Any] = [:]

        if let placeholderFont = placeholderFont {
            let scaledSize = UIFontMetrics.default.scaledValue(for: placeholderFont.pointSize)
            var descriptor = placeholderFont.fontDescriptor
            if placeholderIsItalic {
                if let italicDescriptor = descriptor.withSymbolicTraits(
                    [descriptor.symbolicTraits, .traitItalic]) {
                    descriptor = italicDescriptor
                }
            }
            attributes[.font] = UIFont(descriptor: descriptor, size: scaledSize)
        }

        if let placeholderColor = placeholderColor {
            attributes[.foregroundColor] = placeholderColor
        }

        if placeholderIsUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            if let placeholderUnderlineColor = placeholderUnderlineColor {
                attributes[.underlineColor] = placeholderUnderlineColor
            }
        }

        if placeholderIsStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            if let placeholderStrikethroughColor = placeholderStrikethroughColor {
                attributes[.strikethroughColor] = placeholderStrikethroughColor
            }
        }

        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }

    private func updateFont(_ textField: UITextField) {
        guard let baseFont = baseFont else {
            textField.font = UIFont.systemFont(ofSize: 16.0)
            return
        }

        let scaledSize = UIFontMetrics.default.scaledValue(for: baseFont.pointSize)

        // Get the font descriptor to preserve all font characteristics
        var descriptor = baseFont.fontDescriptor

        // Apply italic if needed
        if isItalic {
            if let italicDescriptor = descriptor.withSymbolicTraits([descriptor.symbolicTraits, .traitItalic]) {
                descriptor = italicDescriptor
            }
        }

        // Create the final font with scaled size
        let font = UIFont(descriptor: descriptor, size: scaledSize)
        textField.font = font

        // Update attributed text styling if text exists, preserving cursor position
        if !text.isEmpty {
            updateTextStyling(textField)
        }
    }

    private func updateTextStyling(_ textField: UITextField) {
        guard !text.isEmpty else { return }

        // Preserve cursor position
        let currentSelectedRange = textField.selectedTextRange

        var attributes: [NSAttributedString.Key: Any] = [:]

        // Apply font with dynamic type scaling
        if let baseFont = baseFont {
            let scaledSize = UIFontMetrics.default.scaledValue(for: baseFont.pointSize)

            // Get the font descriptor to preserve all font characteristics
            var descriptor = baseFont.fontDescriptor

            // Apply italic if needed
            if isItalic {
                if let italicDescriptor = descriptor.withSymbolicTraits([descriptor.symbolicTraits, .traitItalic]) {
                    descriptor = italicDescriptor
                }
            }

            // Create the final font with scaled size
            let finalFont = UIFont(descriptor: descriptor, size: scaledSize)
            attributes[.font] = finalFont
        } else {
            attributes[.font] = UIFont.systemFont(ofSize: 16.0)
        }

        // Apply text color
        if let textColor = textColor {
            attributes[.foregroundColor] = textColor
        }

        // Apply underline
        if isUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            if let underlineColor = underlineColor {
                attributes[.underlineColor] = underlineColor
            }
        }

        // Apply strikethrough
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            if let strikethroughColor = strikethroughColor {
                attributes[.strikethroughColor] = strikethroughColor
            }
        }

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        textField.attributedText = attributedString

        // Restore cursor position
        textField.selectedTextRange = currentSelectedRange
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CursorPositionTextField
        var toolbarAction: (() -> Void)?
        var isUpdatingFromTextField = false

        init(_ parent: CursorPositionTextField) {
            self.parent = parent
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            let text: String

            // Get text from attributed or regular text
            if let attributedText = textField.attributedText {
                text = attributedText.string
            } else {
                text = textField.text ?? ""
            }

            // Set flag to prevent updateUIView from interfering
            isUpdatingFromTextField = true

            // Update the binding
            self.parent.text = text

            // Get current cursor position before any modifications
            let cursorPosition = textField.selectedTextRange?.start
            let currentPosition = cursorPosition != nil ? textField.offset(from: textField.beginningOfDocument, to: cursorPosition!) : 0

            // Format the text and get new cursor position if callback exists
            if let onTextChange = self.parent.onTextChange {
                let newCursorPosition = onTextChange(text, currentPosition)

                // Update styling after text formatting and set cursor position
                self.parent.updateTextStyling(textField)
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorPosition) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            } else {
                // Update styling immediately - cursor position is preserved in updateTextStyling
                self.parent.updateTextStyling(textField)
            }

            isUpdatingFromTextField = false
        }

        @objc func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged(true)
        }

        @objc func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged(false)
            parent.onCommit()
        }

        @objc func toolbarButtonTapped() {
            toolbarAction?()
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit?()
            return true
        }
    }
}
