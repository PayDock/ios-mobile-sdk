//
//  ApplePayWidget.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import PassKit

public struct ApplePayWidget: View {
    @StateObject private var viewModel: ApplePayVM
    @State var appearance: ApplePayWidgetAppearance

    /// Initializes the Apple Pay widget
    /// - Parameters:
    ///   - config: Configuration containing payment request, service ID, and access token
    ///   - appearance: Optional appearance configuration for the button
    ///   - eventDelegate: Optional delegate for widget events
    ///   - completion: Completion handler returning the Paydock OTT token on success
    public init(config: ApplePayWidgetConfig,
                appearance: ApplePayWidgetAppearance = ApplePayWidgetAppearance(),
                eventDelegate: WidgetEventDelegate? = nil,
                completion: @escaping (Result<String, ApplePayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ApplePayVM(
            config: config,
            eventDelegate: eventDelegate,
            completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        ApplePayButton(appearance: appearance) {
            viewModel.startPayment()
            viewModel.handleApplePayTapAnalytics()
        }
    }
}

struct ApplePayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidget(
            config: ApplePayWidgetConfig(
                pkPaymentRequest: .init(),
                serviceId: "test-service-id",
                accessToken: "test-token"
            ),
            completion: { _ in }
        )
    }
}
