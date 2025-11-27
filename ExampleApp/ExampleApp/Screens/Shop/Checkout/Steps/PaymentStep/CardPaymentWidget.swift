//
//  CardPaymentWidget.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

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
                showCardTitle: false,
                collectCardholderName: false,
                allowSaveCard: SaveCardConfig(
                    privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                        privacyPolicyText: "Read our privacy policy",
                        privacyPolicyURL: "https://www.paydock.com/privacy"
                    )
                )
            ),
            appearance: getAppearance(),
            loadingDelegate: viewModel,
            completion: { result in
                switch result {
                case .success(let result):
                    viewModel.payWithCard(result.token)
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
