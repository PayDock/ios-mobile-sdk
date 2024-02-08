//
//  GiftCardWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct GiftCardWidgetView: View {

    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                GiftCardWidget(storePin: false) { result in
                    switch result {
                    case .success(let text): self.alertMessage = text
                    case .failure(let error): self.alertMessage = error.localizedDescription
                    }
                    showAlert = true
                }
            }
            .alert("Gift Card", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidgetView()
    }
}

