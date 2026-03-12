//
//  ZipWidget.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import SwiftUI

public struct ZipWidget: View {
    @StateObject private var viewModel: ZipVM
    @State var appearance: ZipWidgetAppearance

    public init(viewState: ViewState? = nil,
                config: ZipWidgetConfig,
                appearance: ZipWidgetAppearance = ZipWidgetAppearance(),
                loadingDelegate: WidgetLoadingDelegate? = nil,
                eventDelegate: WidgetEventDelegate? = nil,
                completion: @escaping (Result<String, ZipError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ZipVM(
            viewState: viewState ?? ViewState(state: .none),
            config: config,
            loadingDelegate: loadingDelegate,
            eventDelegate: eventDelegate,
            completion: completion))
        self.appearance = appearance
    }

    public var body: some View {
        if viewModel.isLoading && viewModel.showLoaders {
            zipDisabledButton
        } else {
            zipButton
                .sheet(isPresented: $viewModel.showWebView, content: {
                    webViewSheetContent
                })
        }
    }

    private var zipDisabledButton: some View {
        ZStack {
            if viewModel.isLoading && viewModel.showLoaders {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: appearance.loader.spinnerColor))
            } else {
                Image(appearance.buttonStyle.imageName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: .infinity)
        .background(appearance.buttonStyle.backgroundColor)
        .cornerRadius(appearance.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: appearance.cornerRadius)
                .stroke(appearance.buttonStyle.borderColor, lineWidth: appearance.buttonStyle.borderWidth)
        )
        .opacity(viewModel.viewState.isDisabled ? 0.8 : 1.0)
        .accessibilityLabel("Pay with Zip")
        .accessibilityHint("Zip loading...")
    }

    private var zipButton: some View {
        Button {
            viewModel.handleZipButtonTapAnalytics()
            viewModel.handleButtonTap()
        } label: {
            Image(appearance.buttonStyle.imageName, bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: .infinity)
        .background(appearance.buttonStyle.backgroundColor)
        .cornerRadius(appearance.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: appearance.cornerRadius)
                .stroke(appearance.buttonStyle.borderColor, lineWidth: appearance.buttonStyle.borderWidth)
        )
        .disabled(viewModel.viewState.isDisabled)
        .opacity(viewModel.viewState.isDisabled ? 0.8 : 1.0)
        .accessibilityLabel("Pay with Zip")
        .accessibilityHint("Initiates payment using Zip.")
    }

    private func getButtonAppearance() -> Theme.ButtonAppearance {
        let buttonStyle = appearance.buttonStyle

        // Apply Zip brand colors based on selected style
        let colors = Theme.ButtonColors(
            background: buttonStyle.backgroundColor,
            text: .clear,  // Icon-only button
            image: .clear, // Icon color is baked into the asset
            border: buttonStyle.borderColor
        )

        // Zip buttons are icon-only per brand guidelines
        let icon = Image(buttonStyle.imageName, bundle: .module)

        // Create button appearance with Zip branding (icon-only)
        let buttonAppearance = Theme.ButtonAppearance(
            colors: colors,
            dimensions: Theme.ButtonDimensions(
                cornerRadius: appearance.cornerRadius,
                borderWidth: buttonStyle.borderWidth,
            ),
            loader: appearance.loader,
            icon: icon
        )

        return buttonAppearance
    }

    private var webViewSheetContent: some View {
        Group {
            if let url = viewModel.zipUrl {
                ZipWebView(url: url, onApprove: { callbackData in
                    viewModel.handleZipConfirmation(callbackData: callbackData)
                }, onFailure: { error in
                    viewModel.handleWebViewFailure(error)
                })
                .ignoresSafeArea()
            }
        }
        .interactiveDismiss(canDismissSheet: false) {
            viewModel.showCancelConfirmation = true
        }
        .confirmationDialog("Are you sure you want to cancel?",
                            isPresented: $viewModel.showCancelConfirmation, titleVisibility: .visible, actions:
        {
            Button("Yes", role: .destructive) {
                viewModel.showWebView = false
                viewModel.handleSheetCancellation()
            }
            Button("No", role: .cancel) {}
        })
    }
}

struct ZipWidget_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Colored icon on black (default)
            ZipWidget(
                config: ZipWidgetConfig(
                    accessToken: "YOUR-TOKEN",
                    gatewayId: "YOUR-GATEWAY-ID",
                    amount: 100.0,
                    currency: "AUD",
                    firstName: "John",
                    lastName: "Doe",
                    email: "john.doe@example.com",
                    items: [
                        ZipWidgetConfig.Item(name: "Test Item", amount: "100.00", quantity: 1)
                    ]
                ),
                appearance: ZipWidgetAppearance(buttonStyle: .whiteOnBlack),
                completion: { _ in }
            )

            // Colored icon on white with border
            ZipWidget(
                config: ZipWidgetConfig(
                    accessToken: "YOUR-TOKEN",
                    gatewayId: "YOUR-GATEWAY-ID",
                    amount: 100.0,
                    currency: "AUD",
                    firstName: "John",
                    lastName: "Doe",
                    email: "john.doe@example.com",
                    items: [
                        ZipWidgetConfig.Item(name: "Test Item", amount: "100.00", quantity: 1)
                    ]
                ),
                appearance: ZipWidgetAppearance(buttonStyle: .blackOnWhite),
                completion: { _ in }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
