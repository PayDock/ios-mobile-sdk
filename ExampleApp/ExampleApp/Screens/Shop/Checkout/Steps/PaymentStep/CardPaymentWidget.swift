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
                actionText: "Continue",
                showCardTitle: false,
                collectCardholderName: true,
                allowSaveCard: SaveCardConfig(
                    consentText: "Save payment details",
                    privacyPolicyConfig: SaveCardConfig.PrivacyPolicyConfig(
                        privacyPolicyText: "Read our privacy policy",
                        privacyPolicyURL: "https://www.paydock.com/privacy"
                    )
                )
            ),
            loadingDelegate: viewModel,
            completion: { result in
                switch result {
                case .success(let result):
                    viewModel.cardToken = result.token
                    currentStep = .review
                case .failure: break
                }
            }
        )
    }
}
