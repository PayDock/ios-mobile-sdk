//
//  Integrated3DSWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023.
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import SwiftUI
import MobileSDK

struct Integrated3DSWidgetView: View {

    @StateObject private var viewModel = Integrated3DSVM()
    @State var isSheetPresented = false
    @State var onCompletion: ChargeResponse?
    @State var onFailure: PayPalError?

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                        .sheet(isPresented: $viewModel.showWebView) {
                            NavigationStack {
                                VStack {
                                    WebView3DS(
                                        delegate: viewModel.paydockDelegate,
                                        token: viewModel.token3DS,
                                        baseURL: viewModel.getBaseUrl())
                                    .navigationTitle("3DS Check")
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        }
                    Spacer()
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .onAppear {
            viewModel.tokeniseCardDetails()
        }
    }
}

struct 
_Previews: PreviewProvider {
    static var previews: some View {
        Integrated3DSWidgetView()
    }
}
