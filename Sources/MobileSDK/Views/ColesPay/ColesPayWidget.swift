//
//  ColesPayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI

public struct ColesPayWidget: View {

    @StateObject private var viewModel: ColesPayVM

    public init(viewState: ViewState? = nil,
                loadingDelegate: WidgetLoadingDelegate? = nil,
                clientId: String,
                colesPayToken: @escaping (_ colesPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<String, ColesPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: ColesPayVM(
            clientId: clientId,
            colesPayToken: colesPayToken,
            viewState: viewState ?? ViewState(state: .none),
            loadingDelegate: loadingDelegate,
            completion: completion))
    }

    public var body: some View {
        colesPayButton
            .sheet(isPresented: $viewModel.showWebView, content: {
                webViewSheetContent
            })
    }
    
    private var colesPayButton: some View {
        SDKButton(
            title: nil,
            image: Image((viewModel.isLoading && viewModel.showLoaders) ? "coles-pay-button-blank" : "coles-pay-button", bundle: Bundle.module),
            imageLocation: .left,
            isLoading: viewModel.isLoading && viewModel.showLoaders,
            style: .image(ImageButtonStyle(isDisabled: viewModel.viewState.isDisabled, loaderColor: .white)),
            scaleToFit: true) {
                viewModel.handleButtonTap()
            }
            .accessibilityLabel(Text("Pay with Coles Pay"))
    }
    
    private var webViewSheetContent: some View {
        NavigationStack {
            ColesPayWebView(
                clientId: viewModel.clientId ?? "",
                colesPayOrderId: viewModel.colesPayOrderId,
                onApprove: {
                    viewModel.handleSuccess()
                },
                onFailure: { error in
                    viewModel.handleFailure(error: error)
                })
            .navigationTitle("Checkout with Coles Pay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showCancelConfirmation = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .imageScale(.small)
                    }
                }
            }
        }
        .interactiveDismiss(canDismissSheet: false) {
            viewModel.showCancelConfirmation = true
        }
        .confirmationDialog("Are you sure you want to cancel?", isPresented: $viewModel.showCancelConfirmation, titleVisibility: .visible, actions: {
            Button("Yes", role: .destructive) {
                viewModel.showWebView = false
                viewModel.handleSheetCancellation()
            }
            Button("No", role: .cancel) {}
        })
    }
}

struct ColesPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        ColesPayWidget(clientId: "", colesPayToken: { _ in }, completion: { _ in })
    }
}
