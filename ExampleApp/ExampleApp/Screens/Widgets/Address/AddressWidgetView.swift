//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI
import MobileSDK

struct AddressWidgetView: View {
    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                AddressWidget(address: nil) { result in
                    switch result {
                    case .success(let address): alertMessage = address.addressLine1
                    case .failure(let error): alertMessage = error.localizedDescription
                    }
                    showAlert = true
                }
            }
            .alert("Address", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidgetView()
    }
}
