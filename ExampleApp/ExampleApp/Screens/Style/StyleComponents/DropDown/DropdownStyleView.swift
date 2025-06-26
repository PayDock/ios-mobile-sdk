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
                    ResetStyleButton {
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
    
    private var dropdownFontListView: some View {
        VStack (spacing: 16) {
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.dropdownListFont,
                placeholder: "Dropdown list font",
                onSelection: { fontName in
                    viewModel.dropdownListFont = fontName
                })
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
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.textFont,
                placeholder: "Text font",
                onSelection: { fontName in
                    viewModel.textFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.titleFont,
                placeholder: "Title font",
                onSelection: { fontName in
                    viewModel.titleFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.placeholderFont,
                placeholder: "Placeholder font",
                onSelection: { fontName in
                    viewModel.placeholderFont = fontName
                })
            
            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.errorFont,
                placeholder: "Error font",
                onSelection: { fontName in
                    viewModel.errorFont = fontName
                })
        }
    }
}

#Preview {
    DropdownStyleView(selectedWidget: .all, stylingDarkMode: false)
}
