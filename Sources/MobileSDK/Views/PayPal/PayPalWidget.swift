//
//  PayPalWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI
import PaymentButtons
import PayPalWebPayments

public struct PayPalWidget: View {
    @StateObject private var viewModel: PayPalVM
    @State var appearance: PayPalWidgetAppearance

    public init(viewState: ViewState? = nil,
                appearance: PayPalWidgetAppearance = PayPalWidgetAppearance(),
                config: PayPalWidgetConfig,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
                completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        _viewModel = StateObject(wrappedValue: PayPalVM(
            config: config,
            viewState: viewState ?? ViewState(state: .none),
            tokenRequest: tokenRequest,
            loadingDelegate: loadingDelegate,
            completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        PayPalButtonRepresentable(
            insets: appearance.buttonInsets,
            color: appearance.buttonColor,
            edges: appearance.buttonEdges,
            size: appearance.buttonSize,
            label: appearance.buttonLabel,
            isDisabled: viewModel.viewState.isDisabled,
            action: {
                viewModel.handleButtonTap()
            }
        )
        .overlay {
            if viewModel.isLoading && viewModel.showLoaders && appearance.buttonSize != .mini {
                GeometryReader { geometry in
                    ProgressView()
                        .tint(getProgressViewTint())
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                        .background(getProgressViewBackground())
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
    }

    private func getProgressViewBackground() -> Color {
        switch appearance.buttonColor {
        case .gold: return Color(hex: "#FFC439")
        case .white: return Color(hex: "#FFFFFF")
        case .black: return Color(hex: "#000000")
        case .silver: return Color(hex: "#EEEEEE")
        case .blue: return Color(hex: "#0070BA")

        }
    }

    private func getProgressViewTint() -> Color {
        switch appearance.buttonColor {
        case .blue, .black: return .white
        case .white, .gold, .silver: return .black
        }
    }

    private func getButtonAppearance() -> Theme.ButtonAppearance {
        let colors = Theme.ButtonColors(background: Color(red: 1.0, green: 0.76, blue: 0.30))
        let appearance = Theme.ButtonAppearance(colors: colors, loader: appearance.loader)
        return appearance
    }
}

#Preview {
    PayPalWidget(
        config: .init(
            accessToken: "",
            gatewayId: ""),
        loadingDelegate: nil) { _ in } completion: { _ in }
}
