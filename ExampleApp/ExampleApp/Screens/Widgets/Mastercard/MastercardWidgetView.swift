//
//  MastercardWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct MastercardWidgetView: View {

    @StateObject private var viewModel = MastercardWidgetVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                MastercardWidget()
                .padding()
            }
            .background(Color(hex: "#EAE0D7"))
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {}, message: {
                Text(viewModel.alertMessage)
            })
        }
    }
}

struct MastercardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MastercardWidgetView()
    }
}
