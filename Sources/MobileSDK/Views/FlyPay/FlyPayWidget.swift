//
//  FlyPayWidget.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI

public struct FlyPayWidget: View {

    @StateObject private var viewModel: FlyPayVM

    public init(clientId: String, flyPayToken: @escaping (_ flyPayToken: @escaping (String) -> Void) -> Void,
                completion: @escaping (Result<Void, FlyPayError>) -> Void) {
        _viewModel = StateObject(wrappedValue: FlyPayVM(clientId: clientId, flyPayToken: flyPayToken, completion: completion))
    }

    public var body: some View {
        flyPayButton
            .sheet(isPresented: $viewModel.showWebView, content: {
                webViewSheetContent
            })
    }
    
    private var flyPayButton: some View {
        SDKButton(
            title: "Pay with",
            image: Image("flypay", bundle: Bundle.module),
            imageLocation: .right,
            style: .fill(FillButtonStyle(backgroundColor: Color(red: 0.00, green: 0.48, blue: 0.75)))) {
                viewModel.handleButtonTap()
            }
            .accessibilityLabel(Text("Pay with FlyPay"))
            .modifier(ActivityIndicatorModifier(isLoading: viewModel.isLoading))
    }
    
    private var webViewSheetContent: some View {
        NavigationStack {
            FlyPayWebView(
                clientId: viewModel.clientId ?? "",
                flyPayOrderId: viewModel.flyPayOrderId,
                onApprove: {
                    viewModel.handleSuccess()
                },
                onFailure: { error in
                    viewModel.handleFailure(error: error)
                })
            .navigationTitle("Checkout with FlyPay")
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

struct FlyPayWidget_Previews: PreviewProvider {
    static var previews: some View {
        FlyPayWidget(clientId: "", flyPayToken: { _ in }, completion: { _ in })
    }
}
