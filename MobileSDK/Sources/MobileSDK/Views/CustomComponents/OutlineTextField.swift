//
//  OutlineTextField.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

struct OutlineTextField: View {

    // MARK: Properties

    @State private var borderColor = Color.gray
    @State private var borderWidth = 1.0
    @State private var placeholderBackgroundOpacity = 0.0
    @State private var placeholderBottomPadding = 0.0
    @State private var placeholderColor = Color.gray
    @State private var placeholderFontSize = 16.0
    @State private var placeholderLeadingPadding: Double
    @State private var validationIconState: ValidationIconState = .none

    @Binding private var text: String
    @Binding private var valid: Bool
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String

    @FocusState private var focusField: Field?

    private let placeholder: String


    // MARK: - Initialization

    /// Creates a Material Design inspired text field with an animated border and placeholder.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - placeholder: The placeholder string.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    public init(_ text: Binding<String>,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool>) {
        self._text = text
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid

        placeholderLeadingPadding = (leftImage != nil) ? 30 : 8.0
    }

    // MARK: - View protocol properties

    public var body: some View {
        ZStack {
            HStack {
                leftImage?
                    .frame(width: 28, height: 24)
                TextField("", text: $text)
                    .customFont(.body, weight: .normal)
                    .frame(height: 48)
                validationIconView
            }
            .padding([.leading, .trailing], 6.0)
            .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                .stroke(borderColor, lineWidth: borderWidth))

            HStack {
                ZStack {
                    Color(.white)
                        .cornerRadius(4.0)
                        .opacity(placeholderBackgroundOpacity)
                    Text(placeholder)
                        .foregroundColor(.white)
                        .colorMultiply(placeholderColor)
                        .animatableFont(size: placeholderFontSize)
                        .padding([.leading, .trailing], 2.0)
                        .layoutPriority(1)
                }
                .padding([.leading], placeholderLeadingPadding)
                .padding([.bottom], placeholderBottomPadding)
                Spacer()
            }

            HStack {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .customFont(.caption)
                        .font(.system(size: 10.0))
                        .foregroundColor(.red)
                        .padding(.leading, 10.0)
                }
                Spacer()
            }
        }
        .frame(height: 78, alignment: .top)
        .onChange(of: editing) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                updateBorder()
                updatePlaceholder()
            }
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
            borderColor = .red
            validationIconState = .invalid
        } else if editing {
            borderColor = .blue
            validationIconState = .none
        } else {
            borderColor = .gray
            validationIconState = .valid
        }
    }

    func updateBorderWidth() {
        borderWidth = editing ? 2.0 : 1.0
    }

    func updatePlaceholder() {
        updatePlaceholderBackground()
        updatePlaceholderColor()
        updatePlaceholderFontSize()
        updatePlaceholderPosition()
    }

    func updatePlaceholderBackground() {
        if editing || !text.isEmpty {
            placeholderBackgroundOpacity = 1.0
        } else {
            placeholderBackgroundOpacity = 0.0
        }
    }

    func updatePlaceholderColor() {
        if valid {
            placeholderColor = editing ? .blue : .gray
        } else if text.isEmpty {
            placeholderColor = editing ? .red : .gray
        } else {
            placeholderColor = .red
        }
    }

    func updatePlaceholderFontSize() {
        if editing || !text.isEmpty {
            placeholderFontSize = 12.0
        } else {
            placeholderFontSize = 16.0
        }
    }

    func updatePlaceholderPosition() {
        if editing || !text.isEmpty {
            placeholderBottomPadding = 48.0
            placeholderLeadingPadding = 8.0

        } else {
            placeholderBottomPadding = 0.0
            placeholderLeadingPadding = (leftImage != nil) ? 30 : 8.0
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
        OutlineTextField(.constant("Asdf"), placeholder: "Placeholder", errorMessage: .constant("Error message"), editing: .constant(false), valid: .constant(false))
    }

}
