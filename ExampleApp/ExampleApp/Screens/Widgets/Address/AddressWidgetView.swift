//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
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
                AddressWidget(
                    config: .init(),
                    appearance: getAppearance()) { address in
                    alertMessage = address.addressLine1
                    showAlert = true
                }
            }
            .alert("Address", isPresented: $showAlert, actions: {}, message: {
                Text(alertMessage)
            })
        }
    }
    
    private func getAppearance() -> AddressWidgetAppearance {
        // TODO: - For theme testing - pull the data from Style screen once it's implemented and remove test code
        return AddressWidgetAppearance()
//        let appearance = AddressWidgetAppearance(
//            title: .init(text: .init(textColor: .red), padding: .init(top: 10, leading: 5, bottom: 40, trailing: 20)),
//            textfield: .init(colors: .init(), dimensions: .init(padding: .init(top: 50)), fonts: .init()),
//            primaryButton: .init(colors: .init(background: .blue, border: .pink)),
//            expandSectionButton: .init(colors: .init(background: .green, border: .black)),
//            search: .init(dropdown: .init(colors: .init(backgroundColor: .blue), dimensions: .init(padding: 20, listSpacing: 20))))
//        return appearance
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidgetView()
    }
}
