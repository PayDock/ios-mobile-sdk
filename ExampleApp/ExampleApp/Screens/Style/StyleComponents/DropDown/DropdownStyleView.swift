//
//  DropdownStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 13.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct DropdownStyleView: View {

    @StateObject var viewModel: DropdownStyleVM
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: DropdownStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }
    
    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Dropdown")
                    SubsectionTitleView(title: "Colors")
                    dropdownColorListView
                    SubsectionTitleView(title: "Dimensions")
                    dropdownSpacingListView
                    SubsectionTitleView(title: "Padding")
                    dropdownPaddingListView
                    SubsectionTitleView(title: "Fonts")
                    dropdownFontListView
                    
                    SectionTitleView(title: "TextField")
                    SubsectionTitleView(title: "Colors")
                    textFieldColorListView
                    SubsectionTitleView(title: "Dimensions")
                    textFieldDimensionsListView
                    SubsectionTitleView(title: "Padding")
                    textFieldPaddingListView
                    SubsectionTitleView(title: "Fonts")
                    textFieldFontListView
                    ResetStyleButton() {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle("Dropdown")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }
    
    // Dropdown
    
    private var dropdownColorListView: some View {
        VStack (spacing: 16) {
            ColorPickerView(
                title: "Dropdown background color",
                text: Binding(
                    get: { viewModel.dropdownBackgroundColor.toHex() },
                    set: { viewModel.dropdownBackgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.dropdownBackgroundColor)
            
            ColorPickerView(
                title: "Dropdown list color",
                text: Binding(
                    get: { viewModel.dropdownListColor.toHex() },
                    set: { viewModel.dropdownListColor = Color(hex: $0) }),
                pickedColor: $viewModel.dropdownListColor)
        }
    }
    
    private var dropdownPaddingListView: some View {
        VStack (spacing: 16) {
            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.dropdownTopPadding)" },
                    set: { viewModel.dropdownTopPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.dropdownLeadingPadding)" },
                    set: { viewModel.dropdownLeadingPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.dropdownBottomPadding)" },
                    set: { viewModel.dropdownBottomPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.dropdownTrailingPadding)" },
                    set: { viewModel.dropdownTrailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }
    
    private var dropdownSpacingListView: some View {
        VStack (spacing: 16) {
            DimensionsFieldView(
                title: "List Spacing",
                text: Binding(
                    get: { "\(viewModel.dropdownListSpacing)" },
                    set: { viewModel.dropdownListSpacing = CGFloat(Double($0) ?? 0) }))
        }
    }
    
    private var dropdownFontListView: some View {
        VStack (spacing: 16) {
            ColorPickerView(
                title: "Underline color",
                text: Binding(
                    get: { viewModel.dropdownUnderlineColor.toHex() },
                    set: { viewModel.dropdownUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.dropdownUnderlineColor)
            
            ColorPickerView(
                title: "Strikethrough color",
                text: Binding(
                    get: { viewModel.dropdownStrikethroughColor.toHex() },
                    set: { viewModel.dropdownStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.dropdownStrikethroughColor)
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.dropdownListFont,
                placeholder: "Dropdown list font",
                onSelection: { fontName in
                    viewModel.dropdownListFont = fontName
                })
            
            DimensionsFieldView(
                title: "Font size",
                text: Binding(
                    get: { "\(viewModel.dropdownFontSize)" },
                    set: { viewModel.dropdownFontSize = CGFloat(Double($0) ?? 0) }))
        }
    }
    
    // TextField

    private var textFieldColorListView: some View {
        VStack (spacing: 16) {
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
                title: "Background color",
                text: Binding(
                    get: { viewModel.backgroundColor.toHex() },
                    set: { viewModel.backgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.backgroundColor)
        }
    }
    
    private var textFieldDimensionsListView: some View {
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
    
    private var textFieldPaddingListView: some View {
        VStack (spacing: 16) {
            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.textFieldTopPadding)" },
                    set: { viewModel.textFieldTopPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.textFieldLeadingPadding)" },
                    set: { viewModel.textFieldLeadingPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.textFieldBottomPadding)" },
                    set: { viewModel.textFieldBottomPadding = CGFloat(Double($0) ?? 0) }))
            
            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.textFieldTrailingPadding)" },
                    set: { viewModel.textFieldTrailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }
    
    private var textFieldFontListView: some View {
        VStack (spacing: 16) {
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
        }
    }
}

#Preview {
    DropdownStyleView(selectedWidget: .all, stylingDarkMode: false)
}
