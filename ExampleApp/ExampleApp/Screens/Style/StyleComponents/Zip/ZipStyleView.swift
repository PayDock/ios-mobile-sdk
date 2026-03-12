//
//  ZipStyleView.swift
//  ExampleApp
//
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct ZipStyleView: View {

    @StateObject var viewModel: ZipStyleVM

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum, stylingDarkMode: Bool) {
        _viewModel = StateObject(wrappedValue: ZipStyleVM(
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
                .navigationTitle("Zip Button")
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
                entries: viewModel.buttonStyleNames,
                selected: $viewModel.selectedButtonStyleName,
                placeholder: "Select Button Style") { buttonStyleName in
                    viewModel.selectedButtonStyleName = buttonStyleName
                }
        }
    }
}

#Preview {
    ZipStyleView(selectedWidget: .all, stylingDarkMode: false)
}
