//
//  TextFieldStyleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct TextFieldStyleView: View {

    @StateObject var viewModel: TextFieldStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         cardTextFieldKeyPath: WritableKeyPath<CardDetailsWidgetAppearance, Theme.TextFieldAppearance>? = nil,
         giftCardTextFieldKeyPath: WritableKeyPath<GiftCardWidgetAppearance, Theme.TextFieldAppearance?>? = nil,
         addressTextFieldKeyPath: WritableKeyPath<AddressWidgetAppearance, Theme.TextFieldAppearance?>? = nil) {
        _viewModel = StateObject(wrappedValue: TextFieldStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode,
            cardTextFieldKeyPath: cardTextFieldKeyPath,
            giftCardTextFieldKeyPath: giftCardTextFieldKeyPath,
            addressTextFieldKeyPath: addressTextFieldKeyPath))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Colors")
                    colorListView
                    SectionTitleView(title: "Dimensions")
                    dimensionsListView
                    SectionTitleView(title: "Padding")
                    paddingListView
                    SectionTitleView(title: "Fonts")
                    fontListView
                    SectionTitleView(title: "Text Content")
                    textContentListView
                    SectionTitleView(title: "Message Padding")
                    messagePaddingListView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle("Text Field")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var colorListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Active color",
                text: Binding(
                    get: { viewModel.activeColor.toHex() },
                    set: { viewModel.activeColor = Color(hex: $0) }),
                pickedColor: $viewModel.activeColor)

            ColorPickerView(
                title: "Inactive color",
                text: Binding(
                    get: { viewModel.inactiveColor.toHex() },
                    set: { viewModel.inactiveColor = Color(hex: $0) }),
                pickedColor: $viewModel.inactiveColor)

            ColorPickerView(
                title: "Error color",
                text: Binding(
                    get: { viewModel.errorColor.toHex() },
                    set: { viewModel.errorColor = Color(hex: $0) }),
                pickedColor: $viewModel.errorColor)

            ColorPickerView(
                title: "Success color",
                text: Binding(
                    get: { viewModel.successColor.toHex() },
                    set: { viewModel.successColor = Color(hex: $0) }),
                pickedColor: $viewModel.successColor)

            ColorPickerView(
                title: "Text color",
                text: Binding(
                    get: { viewModel.textColor.toHex() },
                    set: { viewModel.textColor = Color(hex: $0) }),
                pickedColor: $viewModel.textColor)

            ColorPickerView(
                title: "Placeholder color",
                text: Binding(
                    get: { viewModel.placeholderColor.toHex() },
                    set: { viewModel.placeholderColor = Color(hex: $0) }),
                pickedColor: $viewModel.placeholderColor)

            ColorPickerView(
                title: "Hint color",
                text: Binding(
                    get: { viewModel.hintColor.toHex() },
                    set: { viewModel.hintColor = Color(hex: $0) }),
                pickedColor: $viewModel.hintColor)

            ColorPickerView(
                title: "Icon color",
                text: Binding(
                    get: { viewModel.iconColor.toHex() },
                    set: { viewModel.iconColor = Color(hex: $0) }),
                pickedColor: $viewModel.iconColor)

            ColorPickerView(
                title: "Background color",
                text: Binding(
                    get: { viewModel.backgroundColor.toHex() },
                    set: { viewModel.backgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.backgroundColor)
        }
    }

    private var dimensionsListView: some View {
        VStack {
            DimensionsFieldView(
                title: "Corner radius",
                text: Binding(
                    get: { "\(viewModel.cornerRadius)" },
                    set: { viewModel.cornerRadius = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Border width",
                text: Binding(
                    get: { "\(viewModel.borderWidth)" },
                    set: { viewModel.borderWidth = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Active border width",
                text: Binding(
                    get: { "\(viewModel.activeBorderWidth)" },
                    set: { viewModel.activeBorderWidth = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var paddingListView: some View {
        VStack(spacing: 16) {
            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.topPadding)" },
                    set: { viewModel.topPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.leadingPadding)" },
                    set: { viewModel.leadingPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.bottomPadding)" },
                    set: { viewModel.bottomPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.trailingPadding)" },
                    set: { viewModel.trailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var fontListView: some View {
        VStack(spacing: 16) {
            // Text
            SubsectionTitleView(title: "Text")
            ColorPickerView(
                title: "Text underline color",
                text: Binding(
                    get: { viewModel.textUnderlineColor.toHex() },
                    set: { viewModel.textUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.textUnderlineColor)

            ColorPickerView(
                title: "Text strikethrough color",
                text: Binding(
                    get: { viewModel.textStrikethroughColor.toHex() },
                    set: { viewModel.textStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.textStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.textFont,
                placeholder: "Text font",
                onSelection: { fontName in
                    viewModel.textFont = fontName
                })

            DimensionsFieldView(
                title: "Text font size",
                text: Binding(
                    get: { "\(viewModel.textFontSize)" },
                    set: { viewModel.textFontSize = CGFloat(Double($0) ?? 0) }))

            // MARK: - Title
            SubsectionTitleView(title: "Title")

            ColorPickerView(
                title: "Title underline color",
                text: Binding(
                    get: { viewModel.titleUnderlineColor.toHex() },
                    set: { viewModel.titleUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.titleUnderlineColor)

            ColorPickerView(
                title: "Title strikethrough color",
                text: Binding(
                    get: { viewModel.titleStrikethroughColor.toHex() },
                    set: { viewModel.titleStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.titleStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.titleFont,
                placeholder: "Title font",
                onSelection: { fontName in
                    viewModel.titleFont = fontName
                })

            DimensionsFieldView(
                title: "Title font size",
                text: Binding(
                    get: { "\(viewModel.titleFontSize)" },
                    set: { viewModel.titleFontSize = CGFloat(Double($0) ?? 0) }))

            // MARK: - Placeholder

            SubsectionTitleView(title: "Placeholder")
            ColorPickerView(
                title: "Placeholder underline color",
                text: Binding(
                    get: { viewModel.placeholderUnderlineColor.toHex() },
                    set: { viewModel.placeholderUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.placeholderUnderlineColor)

            ColorPickerView(
                title: "Placeholder strikethrough color",
                text: Binding(
                    get: { viewModel.placeholderStrikethroughColor.toHex() },
                    set: { viewModel.placeholderStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.placeholderStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.placeholderFont,
                placeholder: "Placeholder font",
                onSelection: { fontName in
                    viewModel.placeholderFont = fontName
                })

            DimensionsFieldView(
                title: "Placeholder font size",
                text: Binding(
                    get: { "\(viewModel.placeholderFontSize)" },
                    set: { viewModel.placeholderFontSize = CGFloat(Double($0) ?? 0) }))

            // MARK: - Error

            SubsectionTitleView(title: "Error")
            ColorPickerView(
                title: "Error underline color",
                text: Binding(
                    get: { viewModel.errorUnderlineColor.toHex() },
                    set: { viewModel.errorUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.errorUnderlineColor)

            ColorPickerView(
                title: "Error strikethrough color",
                text: Binding(
                    get: { viewModel.errorStrikethroughColor.toHex() },
                    set: { viewModel.errorStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.errorStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.errorFont,
                placeholder: "Error font",
                onSelection: { fontName in
                    viewModel.errorFont = fontName
                })

            DimensionsFieldView(
                title: "Error font size",
                text: Binding(
                    get: { "\(viewModel.errorFontSize)" },
                    set: { viewModel.errorFontSize = CGFloat(Double($0) ?? 0) }))

            // MARK: - Hint

            SubsectionTitleView(title: "Hint")
            ColorPickerView(
                title: "Hint underline color",
                text: Binding(
                    get: { viewModel.hintUnderlineColor.toHex() },
                    set: { viewModel.hintUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.hintUnderlineColor)

            ColorPickerView(
                title: "Hint strikethrough color",
                text: Binding(
                    get: { viewModel.hintStrikethroughColor.toHex() },
                    set: { viewModel.hintStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.hintStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.hintFont,
                placeholder: "Hint font",
                onSelection: { fontName in
                    viewModel.hintFont = fontName
                })

            DimensionsFieldView(
                title: "Hint font size",
                text: Binding(
                    get: { "\(viewModel.hintFontSize)" },
                    set: { viewModel.hintFontSize = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var textContentListView: some View {
        VStack(spacing: 16) {
            DimensionsFieldView(
                title: "Placeholder Text",
                text: Binding(
                    get: { viewModel.placeholderText },
                    set: { viewModel.placeholderText = $0 }))

            DimensionsFieldView(
                title: "Hint Text",
                text: Binding(
                    get: { viewModel.hintText },
                    set: { viewModel.hintText = $0 }))

            DimensionsFieldView(
                title: "Accessibility Hint",
                text: Binding(
                    get: { viewModel.accessibilityHintText },
                    set: { viewModel.accessibilityHintText = $0 }))
        }
    }

    private var messagePaddingListView: some View {
        VStack(spacing: 16) {
            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.messageTopPadding)" },
                    set: { viewModel.messageTopPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.messageLeadingPadding)" },
                    set: { viewModel.messageLeadingPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.messageBottomPadding)" },
                    set: { viewModel.messageBottomPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.messageTrailingPadding)" },
                    set: { viewModel.messageTrailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }
}

#Preview {
    TextFieldStyleView(selectedWidget: .all, stylingDarkMode: false)
}
