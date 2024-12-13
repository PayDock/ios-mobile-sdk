//
//  OutlineTextField.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    // MARK: Properties

    @State private var borderColor = Color.borderColor
    @State private var borderWidth: CGFloat = .borderWidth

    @State private var titleBackgroundOpacity = 0.0
    @State private var titleBottomPadding = 0.0
    @State private var titleColor = Color.placeholderColor
    @State private var titleFontSize = 16.0
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
    ///   - onTapGesture: Action to take on tap gesture activaction.
    public init(text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool?>,
                disabled: Binding<Bool>,
                validationIconEnabled: Bool = true,
                onTapGesture: @escaping (() -> Void)
    ) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._disabled = disabled
        self.validationIconEnabled = validationIconEnabled
        self.onTapGesture = onTapGesture

        titleLeadingPadding = (leftImage != nil) ? 52 : 12
    }

    // MARK: - View protocol properties

    public var body: some View {
        VStack {
            ZStack {
                textFieldView
                placeholderView()
            }
            if showErrorView {
                errorView()
            } else {
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .padding(.top, 0)
        .padding(.bottom, 0)
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
        .onChange(of: disabled) { _ in
            
        }
    }

    private var textFieldView: some View {
        HStack {
            leftImage?
                .foregroundColor(.placeholderColor)
                .frame(width: 28, height: 24)

            TextField(editing ? placeholder : "", text: $text)
            .simultaneousGesture(TapGesture().onEnded({ _ in
                onTapGesture()
            }))
            .disabled(disabled)
            .frame(height: 48)
            .customFont(.body)
            .foregroundColor(.textColor)
            .tint(.primaryColor)
            
            if validationIconEnabled {
                validationIconView
            }
        }
        .padding([.leading, .trailing], 16.0)
        .background(RoundedRectangle(cornerRadius: .textFieldCornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: borderWidth))
    }

    private func placeholderView() -> some View {
        HStack {
            ZStack {
                Color.backgroundColor
                    .opacity(titleBackgroundOpacity)
                Text(title)
                    .foregroundColor(.white)
                    .colorMultiply(titleColor)
                    .animatableFont(size: titleFontSize)
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
                    .customFont(.caption)
                    .font(.system(size: 10.0))
                    .foregroundColor(.errorColor)
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
                    .foregroundColor(.successColor)
            case .invalid:
                Image("exclamation-circle", bundle: Bundle.module)
                    .foregroundColor(.errorColor)
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
            borderColor = editing ? .primaryColor : .borderColor
            validationIconState = .none
            return
        }
        if !valid {
            borderColor = .errorColor
            validationIconState = .invalid
        } else if editing {
            borderColor = .primaryColor
            validationIconState = .none
        } else {
            borderColor = .borderColor
            validationIconState = text.isEmpty ? .none : .valid
        }
    }

    func updateBorderWidth() {
        borderWidth = editing ? .borderWidth * 2 : .borderWidth
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
            titleColor = editing ? .primaryColor : .borderColor
            return
        }
        if valid {
            titleColor = editing ? .primaryColor : .borderColor
        } else if text.isEmpty {
            titleColor = editing ? .errorColor : .placeholderColor
        } else {
            titleColor = .errorColor
        }
    }

    func updateTitleFontSize() {
        if editing || !text.isEmpty {
            titleFontSize = 12.0
        } else {
            titleFontSize = 16.0
        }
    }

    func updateTitlePosition() {
        if editing || !text.isEmpty {
            titleBottomPadding = 48.0
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
