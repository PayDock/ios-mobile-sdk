//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI
import MobileSDK

struct AddressWidgetView: View {
    @StateObject var viewModel = AddressWidgetVM()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            AddressWidget(
                config: viewModel.getConfig(),
                appearance: getAppearance(),
                eventDelegate: viewModel) { address in
                    viewModel.handleAddressCompletion(address)
                }
                .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                    Text(viewModel.alertMessage)
                })
        }
    }

    private func getAppearance() -> AddressWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .address,
            isDarkMode: colorScheme == .dark,
            as: AddressWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? AddressWidgetAppearance()
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidgetView()
    }
}
