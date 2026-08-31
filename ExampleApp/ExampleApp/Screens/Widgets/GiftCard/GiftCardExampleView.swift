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
                    // Only attach when the custom button is in use (showSubmitButton = false),
                    // so the internal button keeps its own native spinner otherwise.
                    loadingDelegate: viewModel.getConfig().showSubmitButton ? nil : viewModel,
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
                    let isSubmitDisabled = viewModel.isSubmitting ||
                        (!viewModel.getConfig().activePrimaryButton && !isFormValid)
                    Button(action: {
                        submitTrigger = true
                    }, label: {
                        HStack(spacing: 6) {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Gift Card (custom button)")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.defaultPrimary)
                        .cornerRadius(8)
                        .opacity(isSubmitDisabled ? 0.5 : 1.0)
                    })
                    .accessibilityIdentifier("Add Gift Card Custom Button")
                    .disabled(isSubmitDisabled)
                    .padding(.all, 16)
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
