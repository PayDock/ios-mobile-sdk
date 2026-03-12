//
//  AutocompleteTextField.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

struct AutocompleteTextField: View {

    // MARK: - Dependencies

    @State var appearance: Theme.SearchDropdownAppearance

    // MARK: - OutlineTextField Properties

    @Binding private var text: String
    @Binding private var valid: Bool?
    @Binding private var leftImage: Image?
    @Binding private var editing: Bool
    @Binding private var errorMessage: String
    private let title: String
    private let placeholder: String
    private let onTapGesture: () -> Void
    private let validationIconEnabled: Bool
    private let returnKeyType: UIReturnKeyType
    private let onTextChange: ((String, Int) -> Int)?
    private let onSubmit: (() -> Void)?
    private let keyboardType: UIKeyboardType

    // MARK: - AutocompleteTextField Properties

    @Binding private var showPopup: Bool
    @Binding private var disabled: Bool
    @Binding private var options: [String]
    private var textContentType: UITextContentType?
    @State private var popupOpacity: CGFloat = 0
    @State private var popupScale = 0.7
    private var onSelection: (Int?) -> Void

    @FocusState private var focusField: Field?

    // MARK: - Initialization

    /// Creates a Material Design inspired text field with  an animated border, title and autocomplete popup menu.
    /// - Parameters:
    ///   - text: The text field contents.
    ///   - title: The title string.
    ///   - placeholder: Placeholder that appears when field is active.
    ///   - errorMessage: The field error message string.
    ///   - editing: Whether the field is in the editing state.
    ///   - valid: Whether the field is in the valid state.
    ///   - showPopup: Whether the autocomplete field is displayed..
    ///   - textContentType: Content type used for the suggested prefill.
    ///   - option: Autocomplete popup list of options.
    ///   - onSelection: Returns selected value
    ///
    public init(appearance: Theme.SearchDropdownAppearance = Theme.SearchDropdownAppearance(),
                text: Binding<String>,
                title: String,
                placeholder: String,
                errorMessage: Binding<String>,
                leftImage: Binding<Image?>? = nil,
                editing: Binding<Bool>,
                valid: Binding<Bool?>,
                showPopup: Binding<Bool>,
                disabled: Binding<Bool>,
                validationIconEnabled: Bool = false,
                options: Binding<[String]>,
                textContentType: UITextContentType? = nil,
                onSelection: @escaping (Int?) -> Void,
                onTapGesture: @escaping () -> Void,
                keyboardType: UIKeyboardType = .default,
                returnKeyType: UIReturnKeyType = .default,
                onTextChange: ((String, Int) -> Int)? = nil,
                onSubmit: (() -> Void)? = nil) {
        self.appearance = appearance
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self._errorMessage = errorMessage
        self._leftImage = leftImage ?? .constant(nil)
        self._editing = editing
        self._valid = valid
        self._showPopup = showPopup
        self._disabled = disabled
        self.validationIconEnabled = validationIconEnabled
        self._options = options
        self.textContentType = textContentType
        self.onSelection = onSelection
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.onTapGesture = onTapGesture
        self.onTextChange = onTextChange
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OutlineTextField(
                appearance: appearance.textField,
                text: $text,
                title: title,
                placeholder: placeholder,
                errorMessage: $errorMessage,
                editing: $editing,
                valid: $valid,
                disabled: $disabled,
                validationIconEnabled: validationIconEnabled,
                textContentType: textContentType,
                keyboardType: keyboardType,
                returnKeyType: returnKeyType,
                onTapGesture: onTapGesture,
                onTextChange: onTextChange,
                onSubmit: onSubmit
            )

            // Display popup directly below the text field
            if showPopup && editing {
                autocompletePopup
                    .accessibilityElement(children: .contain)
            }
        }
    }

    private var autocompletePopup: some View {
        autocompletePopupContent
            .opacity(popupOpacity)
            .scaleEffect(popupScale, anchor: .top)
            .onAppear {
                withAnimation(.easeOut(duration: 0.15)) {
                    popupOpacity = 1
                    popupScale = 1
                }
            }
            .onDisappear {
                popupOpacity = 0
                popupScale = 0.7
            }
    }

    private var autocompletePopupContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if options.isEmpty {
                emptyStateView
            } else {
                optionsListView
            }
        }
        .animation(.easeInOut(duration: 0.25), value: options)
        .customPadding(appearance.dropdown.dimensions.padding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(popupBackgroundView)
    }

    private var emptyStateView: some View {
        Text("No results")
            .font(appearance.dropdown.text.listText.text.customFont.scaledFont)
            .foregroundColor(appearance.dropdown.text.listText.text.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .accessibilityLabel(Text("Dropdown menu has no results."))
            .transition(.opacity)
    }

    private var optionsListView: some View {
        ForEach(Array(options.prefix(3)), id: \.self) { option in
            optionRowView(for: option)
        }
    }

    private func optionRowView(for option: String) -> some View {
        HStack(alignment: .top) {
            Text(option)
                .applyAttributesWithScaledFont(appearance.dropdown.text.listText.text)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, appearance.dropdown.dimensions.listSpacing)
                .onTapGesture {
                    onSelection(getOptionIndex(option: option))
                }
                .accessibilityAddTraits(.isButton)
            Spacer(minLength: 0)
        }
        .transition(.opacity)
    }

    private var popupBackgroundView: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(appearance.dropdown.colors.backgroundColor)
            .shadow(radius: 4)
    }

    private func getOptionIndex(option: String) -> Int? {
        return options.firstIndex { $0 == option }
    }

    enum Field {
        case textField
    }
}

// MARK: - AutocompleteTextField_Previews

struct AutocompleteTextField_Previews: PreviewProvider {

    static var options = ["Australia", "Canada"]
    static var previews: some View {
        AutocompleteTextField(
            text: .constant("Search countries here"),
            title: "Select countries",
            placeholder: "",
            errorMessage: .constant(""),
            editing: .constant(true),
            valid: .constant(true),
            showPopup: .constant(true),
            disabled: .constant(false),
            options: .constant(options), onSelection: {_ in },
            onTapGesture: {}
        )
    }
}
