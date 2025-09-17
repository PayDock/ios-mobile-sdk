//
//  PayPalStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 09.09.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI

struct PayPalStyleView: View {

    @StateObject var viewModel: PayPalStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: PayPalStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Style")
                    stylePickersView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle("PayPal Button")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var stylePickersView: some View {
        VStack(spacing: 16) {
            PickerView(
                entries: viewModel.buttonColorNames,
                selected: $viewModel.selectedButtonColorName,
                placeholder: "Select Button Color") { buttonColorName in
                    viewModel.selectedButtonColorName = buttonColorName
                }

            PickerView(
                entries: viewModel.buttonEdgesNames,
                selected: $viewModel.selectedButtonEdgeName,
                placeholder: "Select Button Edges") { buttonEdgesName in
                    viewModel.selectedButtonEdgeName = buttonEdgesName
                }

            PickerView(
                entries: viewModel.buttonSizesNames,
                selected: $viewModel.selectedButtonSizeName,
                placeholder: "Select Button Size") { buttonSizeName in
                    viewModel.selectedButtonSizeName = buttonSizeName
                }

            PickerView(
                entries: viewModel.buttonLabelNames,
                selected: $viewModel.selectedButtonLabelName,
                placeholder: "Select Button Label") { buttonLabelName in
                    viewModel.selectedButtonLabelName = buttonLabelName
                }
        }
    }
}

#Preview {
    PayPalStyleView(selectedWidget: .all, stylingDarkMode: false)
}
