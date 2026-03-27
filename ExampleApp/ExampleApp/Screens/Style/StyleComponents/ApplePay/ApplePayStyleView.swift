//
//  ApplePayStyleView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 23.06.2025..
//  Copyright 2025 Paydock Ltd. All rights reserved.

import SwiftUI

struct ApplePayStyleView: View {

    @StateObject var viewModel: ApplePayStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: ApplePayStyleVM(
            selectedWidget: selectedWidget,
            stylingDarkMode: stylingDarkMode))
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    SectionTitleView(title: "Style")
                    pickerListView
                    ResetStyleButton {
                        viewModel.showResetConfirmation = true
                    }
                }
                .navigationTitle("Apple Pay Button")
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .resetConfirmationAlert(isPresented: $viewModel.showResetConfirmation) {
            viewModel.resetAppearance()
        }
    }

    private var pickerListView: some View {
        VStack(spacing: 16) {
            PickerView(
                entries: viewModel.buttonTypeNames,
                selected: $viewModel.selectedButtonTypeName,
                placeholder: "Select Type") { buttonTypeName in
                    viewModel.selectedButtonTypeName = buttonTypeName
                }

            PickerView(
                entries: viewModel.buttonStyleNames,
                selected: $viewModel.selectedButtonStyleName,
                placeholder: "Select Style") { buttonStyleName in
                    viewModel.selectedButtonStyleName = buttonStyleName
                }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Corner Radius")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.0f pt", viewModel.cornerRadius))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Slider(value: $viewModel.cornerRadius, in: 0...20, step: 1)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ApplePayStyleView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayStyleView(selectedWidget: .all, stylingDarkMode: false)
    }
}
