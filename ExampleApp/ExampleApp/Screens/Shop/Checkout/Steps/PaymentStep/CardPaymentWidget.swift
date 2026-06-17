//
//  CardPaymentWidget.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

struct CardPaymentWidget: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM
    @Binding var currentStep: CheckoutStep

    var body: some View {
        CardDetailsWidget(
            viewState: viewModel.viewState,
            config: CardDetailsWidgetConfig(
                gatewayId: nil,
                accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
                collectCardholderName: false,
                allowSaveCard: SaveCardConfig(
                    privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                        privacyPolicyText: "Read our privacy policy",
                        privacyPolicyURL: "https://www.paydock.com/privacy"
                    )
                ),
                storeSecurityCode: true,
                activePrimaryButton: true
            ),
            appearance: getAppearance(),
            loadingDelegate: viewModel,
            completion: { result in
                switch result {
                case .success(let result):
                    viewModel.payWithOTT(result.token)
                case .failure(let error):
                    viewModel.showResultOverlay(success: false, message: error.customMessage)
                }
            }
        )
    }

    private func getAppearance() -> CardDetailsWidgetAppearance {
        var appearance = CardDetailsWidgetAppearance()
        appearance.actionButton.icon = Image("card-icon")
        return appearance
    }
}
