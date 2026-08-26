//
//  GiftCardExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct GiftCardExampleView: View {

    @StateObject var viewModel = GiftCardExampleVM()
    @Environment(\.colorScheme) var colorScheme

    // Demo of `showSubmitButton: false` — a host-owned button drives the widget's submission via
    // `submitTrigger`. Whether the button should be disabled until valid depends on the host's own
    // `activePrimaryButton` choice: `true` means the internal button would stay enabled and validate
    // on tap, so the custom button mirrors that (always enabled); `false` means it would stay disabled
    // until valid, so the custom button disables via `onFormValidityChange`. This config uses
    // `activePrimaryButton: true` (see `ConfigManager.setupGiftCardConfiguration`), so the modifier
    // below is a no-op here — it's written generically to match whichever value the config uses.
    @State private var submitTrigger = false
    @State private var isFormValid = false

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget(
                    config: viewModel.getConfig(),
                    appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                    eventDelegate: viewModel,
                    submitTrigger: $submitTrigger,
                    onFormValidityChange: { isFormValid = $0 },
                    completion: { result in
                        switch result {
                        case .success(let giftCardResult):
                            viewModel.handleSuccess(giftCardResult)
                        case .failure(let error):
                            viewModel.handleError(error)
                        }
                    })

                if !viewModel.getConfig().showSubmitButton {
                    Button("Add Gift Card (custom button)") {
                        submitTrigger = true
                    }
                    .disabled(!viewModel.getConfig().activePrimaryButton && !isFormValid)
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardExampleView()
    }
}
