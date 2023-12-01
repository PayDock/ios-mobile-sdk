//
//  Standalone3DSWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 29.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct Standalone3DSWidgetView: View {

    @StateObject private var viewModel = Standalone3DSVM()
    @State var isSheetPresented = false
    @State var onCompletion: ChargeResponse?
    @State var onFailure: PayPalError?

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                        .sheet(isPresented: $viewModel.showWebView, onDismiss: {
                            if !viewModel.alertMessage.isEmpty {
                                viewModel.showAlert = true
                            }
                        }) {
                            NavigationStack {
                                VStack {
                                    ThreeDSView(
                                        token: viewModel.token3DS,
                                        baseURL: viewModel.getBaseUrl(),
                                        completionHandler: { event in
                                            viewModel.handle3dsEvent(event)
                                        })
                                    .navigationTitle("3DS Check")
                                    .navigationBarTitleDisplayMode(.inline)

                                }
                            }
                        }
                    if viewModel.alertMessage.isEmpty {
                        ProgressView()
                    }
                    Spacer()
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .alert("3DS", isPresented: $viewModel.showAlert, actions: {}, message: {
            Text(viewModel.alertMessage)
        })
        .onAppear {
            viewModel.getValutToken()
        }
    }
}

struct Standalone3DSWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Standalone3DSWidgetView()
    }
}
