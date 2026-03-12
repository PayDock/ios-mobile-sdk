//
//  AddressExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct AddressExampleView: View {
    @StateObject var viewModel = AddressExampleVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            AddressWidget(
                config: viewModel.getConfig(),
                appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                eventDelegate: viewModel) { address in
                    viewModel.handleAddressCompletion(address)
                }
                .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                    Text(viewModel.alertMessage)
                })
        }
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressExampleView()
    }
}
