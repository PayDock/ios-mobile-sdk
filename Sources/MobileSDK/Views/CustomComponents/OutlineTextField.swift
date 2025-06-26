//
//  OutlineTextField.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    @Environment(\.dynamicTypeSize) var sizeCategory
    
    // MARK: Properties
    
    @State private var appearance: Theme.TextFieldAppearance

    @State private var borderColor = Color.clear
    @State private var borderWidth: CGFloat = 0.0

    @State private var titleBackgroundOpacity = 0.0
    @State private var titleBottomPadding = 0.0
    @State private var titleColor = Color.clear
    @State private var titleFontSize = 0.0
    @State private var titleVerticalPadding: CGFloat = 0
    @State private var titleLeadingPadding: Double

    @State private var validationIconState: ValidationIconState = .none

    @State private var errorViewOpacity: Double = 0
    @State private var errorViewScale = 0
    @State private var showErrorView = false

    @Binding private var text: String
    @Binding private var valid: Bool?
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String
    @Binding private var disabled: Bool

    private let title: String
    private let placeholder: String
    private let validationIconEnabled: Bool
    private let textContentType: UITextContentType?
    private let onTapGesture: () -> Void

    // MARK: - Initialization

    /// Creates a Material Design inspired text field with an animated border and title.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - title: The title string.
    ///   - placeholder: Placeholder that appears when field is active.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    ///   - disabled: Whether the field is in a disabled state.
    ///   - validationIconEnabled: Whether to enabled the validation icon.
    ///   - textContentType: Content type used for the suggested prefill.
    ///   - onTapGesture: Action to take on tap gesture activaction.
    public init(appearance: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
                text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool?>,
                disabled: Binding<Bool>,
                validationIconEnabled: Bool = true,
                textContentType: UITextContentType? = nil,
                onTapGesture: @escaping (() -> Void)
    ) {
        self.appearance = appearance
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._disabled = disabled
        self.validationIconEnabled = validationIconEnabled
        self.textContentType = textContentType
        self.onTapGesture = onTapGesture

        titleLeadingPadding = (leftImage != nil) ? 52 : 12
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
            } else {
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .padding(.top, appearance.dimensions.padding.top)
        .padding(.leading, appearance.dimensions.padding.leading)
        .padding(.bottom, appearance.dimensions.padding.bottom)
        .padding(.trailing, appearance.dimensions.padding.trailing)
        .onTapGesture {
            onTapGesture()
        }
        .onChange(of: editing) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                updateBorder()
                updateTitle()
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
        .onAppear {
            titleColor = appearance.colors.placeholder
            titleFontSize = appearance.fonts.title.customFont.size
            borderColor = appearance.colors.inactive
            borderWidth = appearance.dimensions.borderWidth
        }
    }

    private var textFieldView: some View {
        HStack {
            leftImage?
                .foregroundColor(appearance.colors.placeholder)
                .frame(width: 28, height: 24)
                .accessibilityHidden(true)
            
            TextField(editing ? placeholder : "", text: $text)
                .textContentType(textContentType)
                .simultaneousGesture(TapGesture().onEnded({ _ in
                    onTapGesture()
                }))
                .simultaneousGesture(LongPressGesture().onEnded({ _ in
                    onTapGesture()
                }))
                .disabled(disabled)
                .frame(height: getTextFieldHeight())
                .font(appearance.fonts.text.customFont.font)
                .underline(appearance.fonts.text.isUnderlined, color: appearance.fonts.text.underlineColor)
                .strikethrough(appearance.fonts.text.isStrikethrough, color: appearance.fonts.text.strikethroughColor)
                .italic(appearance.fonts.text.isItalic)
                .foregroundColor(appearance.colors.text)
                .tint(appearance.colors.active)
                .accessibilityLabel(title)
                .accessibilityHint(getValidMessage())
            
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
                    .animatableFont(size: titleFontSize, fontName: appearance.fonts.title.customFont.name)
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
        HStack {
            VStack {
                Text(errorMessage)
                    .font(appearance.fonts.error.customFont.font)
                    .foregroundColor(appearance.colors.error)
                    .padding(.leading, 16.0)
            }
            Spacer()
        }
        .padding(.bottom, 10)
        .opacity(errorViewOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) {
                errorViewOpacity = 1
            }
        }
        .onDisappear {
            withAnimation(.easeOut(duration: 0.15)) {
                errorViewOpacity = 0
            }
        }
    }

    private var validationIconView: some View {
        HStack {
            switch validationIconState {
            case .valid:
                Image("tick-circle", bundle: Bundle.module)
                    .foregroundColor(appearance.colors.success)
            case .invalid:
                Image("exclamation-circle", bundle: Bundle.module)
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
        updateTitlePosition()
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
            titleColor = editing ? appearance.colors.active : appearance.colors.placeholder
            return
        }
        if valid {
            titleColor = editing ? appearance.colors.active : appearance.colors.placeholder
        } else if text.isEmpty {
            titleColor = editing ? appearance.colors.error : appearance.colors.placeholder
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

    func updateTitlePosition() {
        if editing || !text.isEmpty {
            titleBottomPadding = 48.0 + getTitleExtraPadding()
            titleLeadingPadding = 14.0
            titleVerticalPadding = -10

        } else {
            titleBottomPadding = 0.0
            titleLeadingPadding = (leftImage != nil) ? 52 : 14.0
            titleVerticalPadding = 0
        }
    }

    enum Field {
        case textField
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
    
    private func getValidMessage() -> String {
        guard let valid = valid else { return "" }
        return valid ? "Valid" : "Invalid. \(errorMessage)"
    }
}

// MARK: - OutlineTextField_Previews

struct OutlineTextField_Previews: PreviewProvider {

    static var previews: some View {
        OutlineTextField(
            text: .constant("Text"),
            title: "Title",
            placeholder: "Placeholder",
            errorMessage: .constant("Error message"),
            editing: .constant(false),
            valid: .constant(false),
            disabled: .constant(false),
            onTapGesture: {}
        )
    }
}
