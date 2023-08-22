//
//  OutlineTextField.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    // MARK: Properties

    @State private var borderColor = Color.paydockGray
    @State private var borderWidth = 1.0
    @State private var titleBackgroundOpacity = 0.0
    @State private var titleBottomPadding = 0.0
    @State private var titleColor = Color.paydockGray
    @State private var titleFontSize = 16.0
    @State private var titleLeadingPadding: Double
    @State private var validationIconState: ValidationIconState = .none

    @Binding private var text: String
    @Binding private var valid: Bool
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String

    @FocusState private var focusField: Field?

    private let title: String
    private let placeholder: String


    // MARK: - Initialization

    /// Creates a Material Design inspired text field with an animated border and title.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - title: The title string.
    ///   - placeholder: Placeholder that appears when field is active.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    public init(text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool>) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid

        titleLeadingPadding = (leftImage != nil) ? 52 : 12
    }

    // MARK: - View protocol properties

    public var body: some View {
        ZStack {
            textFieldView()
            placeholderView()
            errorView()
        }
        .frame(height: 78, alignment: .top)
        .onChange(of: editing) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                updateBorder()
                updateTitle()
            }
        }
    }

    private func textFieldView() -> some View {
        HStack {
            leftImage?
                .foregroundColor(.paydockGray)
                .frame(width: 28, height: 24)
            TextField(editing ? placeholder : "", text: $text)
                .customFont(.body, weight: .normal)
                .frame(height: 48)
            validationIconView
        }
        .padding([.leading, .trailing], 16.0)
        .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
            .stroke(borderColor, lineWidth: borderWidth))
    }

    private func placeholderView() -> some View {
        HStack {
            ZStack {
                Color(.white)
                    .cornerRadius(4.0)
                    .opacity(titleBackgroundOpacity)
                Text(title)
                    .foregroundColor(.white)
                    .colorMultiply(titleColor)
                    .animatableFont(size: titleFontSize)
                    .padding([.leading, .trailing], 2.0)
                    .layoutPriority(1)
            }
            .padding([.leading], titleLeadingPadding)
            .padding([.bottom], titleBottomPadding)
            Spacer()
        }
    }

    private func errorView() -> some View {
        HStack {
            VStack {
                Spacer()
                Text(errorMessage)
                    .customFont(.caption)
                    .font(.system(size: 10.0))
                    .foregroundColor(.errorRed)
                    .padding(.leading, 10.0)
            }
            Spacer()
        }
    }

    private var validationIconView: some View {
        HStack {
            switch validationIconState {
            case .valid: Image("tick-circle", bundle: Bundle.module)
            case .invalid: Image("exclamation-circle", bundle: Bundle.module)
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
        if !valid {
            borderColor = .errorRed
            validationIconState = .invalid
        } else if editing {
            borderColor = .primaryColor
            validationIconState = .none
        } else {
            borderColor = .paydockGray
            validationIconState = .valid
        }
    }

    func updateBorderWidth() {
        borderWidth = editing ? 2.0 : 1.0
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
        if valid {
            titleColor = editing ? .primaryColor : .paydockGray
        } else if text.isEmpty {
            titleColor = editing ? .errorRed : .paydockGray
        } else {
            titleColor = .errorRed
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

        } else {
            titleBottomPadding = 0.0
            titleLeadingPadding = (leftImage != nil) ? 52 : 14.0
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
            text: .constant("Asdf"),
            title: "Title",
            placeholder: "Placeholder",
            errorMessage: .constant("Error message"),
            editing: .constant(false),
            valid: .constant(false))
    }

}
