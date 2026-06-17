//
//  OverlayLoaderStyleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct OverlayLoaderStyleView: View {

    @StateObject var viewModel: OverlayLoaderStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: OverlayLoaderStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Overlay")
                    overlayListView
                    SectionTitleView(title: "Loader")
                    loaderColorListView
                    SectionTitleView(title: "Card")
                    cardListView
                    SectionTitleView(title: "Text")
                    textListView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle("Overlay Loader")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var overlayListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Background color",
                text: Binding(
                    get: { viewModel.backgroundColor.toHex() },
                    set: { viewModel.backgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.backgroundColor)

            ToggleFieldView(
                title: "Show card",
                isOn: $viewModel.showCard,
                onChange: {})

            PickerView(
                entries: viewModel.allLoaderTypes.map(loaderTypeLabel),
                selected: Binding(
                    get: { loaderTypeLabel(viewModel.loaderType) },
                    set: { viewModel.loaderType = loaderType(from: $0) }),
                placeholder: "Loader type",
                onSelection: { _ in })

            DimensionsFieldView(
                title: "Loader text",
                text: Binding(
                    get: { viewModel.loaderText },
                    set: { viewModel.loaderText = $0 }))

            DimensionsFieldView(
                title: "Loader spacing",
                text: Binding(
                    get: { "\(viewModel.loaderSpacing)" },
                    set: { viewModel.loaderSpacing = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Loader width",
                text: Binding(
                    get: { "\(viewModel.loaderWidth)" },
                    set: { viewModel.loaderWidth = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Loader height",
                text: Binding(
                    get: { "\(viewModel.loaderHeight)" },
                    set: { viewModel.loaderHeight = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var loaderColorListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Loader color",
                text: Binding(
                    get: { viewModel.loaderColor.toHex() },
                    set: { viewModel.loaderColor = Color(hex: $0) }),
                pickedColor: $viewModel.loaderColor)
        }
    }

    private var cardListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Card background color",
                text: Binding(
                    get: { viewModel.cardBackgroundColor.toHex() },
                    set: { viewModel.cardBackgroundColor = Color(hex: $0) }),
                pickedColor: $viewModel.cardBackgroundColor)

            ToggleFieldView(
                title: "Dynamic card size",
                isOn: $viewModel.useDynamicCardSize,
                onChange: {})

            if !viewModel.useDynamicCardSize {
                DimensionsFieldView(
                    title: "Card width",
                    text: Binding(
                        get: { "\(viewModel.cardWidth)" },
                        set: { viewModel.cardWidth = CGFloat(Double($0) ?? 0) }))

                DimensionsFieldView(
                    title: "Card height",
                    text: Binding(
                        get: { "\(viewModel.cardHeight)" },
                        set: { viewModel.cardHeight = CGFloat(Double($0) ?? 0) }))
            }

            DimensionsFieldView(
                title: "Corner radius",
                text: Binding(
                    get: { "\(viewModel.cardCornerRadius)" },
                    set: { viewModel.cardCornerRadius = CGFloat(Double($0) ?? 0) }))

            SubsectionTitleView(title: "Padding")

            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.cardTopPadding)" },
                    set: { viewModel.cardTopPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Left padding",
                text: Binding(
                    get: { "\(viewModel.cardLeftPadding)" },
                    set: { viewModel.cardLeftPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.cardBottomPadding)" },
                    set: { viewModel.cardBottomPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Right padding",
                text: Binding(
                    get: { "\(viewModel.cardRightPadding)" },
                    set: { viewModel.cardRightPadding = CGFloat(Double($0) ?? 0) }))
        }
    }

    private var textListView: some View {
        VStack(spacing: 16) {
            ColorPickerView(
                title: "Text color",
                text: Binding(
                    get: { viewModel.textColor.toHex() },
                    set: { viewModel.textColor = Color(hex: $0) }),
                pickedColor: $viewModel.textColor)

            ColorPickerView(
                title: "Underline color",
                text: Binding(
                    get: { viewModel.textUnderlineColor.toHex() },
                    set: { viewModel.textUnderlineColor = Color(hex: $0) }),
                pickedColor: $viewModel.textUnderlineColor)

            ColorPickerView(
                title: "Strikethrough color",
                text: Binding(
                    get: { viewModel.textStrikethroughColor.toHex() },
                    set: { viewModel.textStrikethroughColor = Color(hex: $0) }),
                pickedColor: $viewModel.textStrikethroughColor)

            PickerView(
                entries: viewModel.allFontNames,
                selected: $viewModel.textFontName,
                placeholder: "Text font",
                onSelection: { fontName in
                    viewModel.textFontName = fontName
                })

            DimensionsFieldView(
                title: "Font size",
                text: Binding(
                    get: { "\(viewModel.textFontSize)" },
                    set: { viewModel.textFontSize = CGFloat(Double($0) ?? 0) }))

            ToggleFieldView(
                title: "Italic",
                isOn: $viewModel.textIsItalic,
                onChange: {})

            ToggleFieldView(
                title: "Underlined",
                isOn: $viewModel.textIsUnderlined,
                onChange: {})

            ToggleFieldView(
                title: "Strikethrough",
                isOn: $viewModel.textIsStrikethrough,
                onChange: {})

            SubsectionTitleView(title: "Padding")

            DimensionsFieldView(
                title: "Top padding",
                text: Binding(
                    get: { "\(viewModel.textTopPadding)" },
                    set: { viewModel.textTopPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Leading padding",
                text: Binding(
                    get: { "\(viewModel.textLeadingPadding)" },
                    set: { viewModel.textLeadingPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Bottom padding",
                text: Binding(
                    get: { "\(viewModel.textBottomPadding)" },
                    set: { viewModel.textBottomPadding = CGFloat(Double($0) ?? 0) }))

            DimensionsFieldView(
                title: "Trailing padding",
                text: Binding(
                    get: { "\(viewModel.textTrailingPadding)" },
                    set: { viewModel.textTrailingPadding = CGFloat(Double($0) ?? 0) }))
        }
    }

    private func loaderTypeLabel(_ type: OverlayLoaderType) -> String {
        switch type {
        case .swiftUIStyle: return "SwiftUI"
        case .uiKitActivityIndicator: return "UIKit Activity Indicator"
        }
    }

    private func loaderType(from label: String) -> OverlayLoaderType {
        viewModel.allLoaderTypes.first { loaderTypeLabel($0) == label } ?? .swiftUIStyle
    }
}

#Preview {
    OverlayLoaderStyleView(selectedWidget: .standalone3ds, stylingDarkMode: false)
}
