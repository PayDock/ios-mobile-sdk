//
//  CardDetailsWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI
import MobileSDK

struct CardDetailsWidgetView: View {
    @State var isSheetPresented = false
    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                CardDetailsWidget(
                    gatewayId: "657045c00b76c9392bf5e36d",
                    completion: { result in
                        switch result {
                        case .success(let token): alertMessage = token
                        case .failure(let error): alertMessage = error.localizedDescription
                        }
                        showAlert = true
                    })
            }
            .alert("Card Details", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidgetView()
    }
}
