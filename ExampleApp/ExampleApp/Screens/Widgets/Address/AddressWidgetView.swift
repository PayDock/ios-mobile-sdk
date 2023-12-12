//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI
import MobileSDK

struct AddressWidgetView: View {
    @State var address: Address = Address()
    @State var isSheetPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                    Button("Launch address sheet") {
                        isSheetPresented = true
                    }
                    .padding()
                    Spacer()
                    
                    AddressWidget { result in
                        switch result {
                        case .success(let address): break
                        case .failure(let error): break
                        }
                    }
                    AddressSheetView(
                        isPresented: $isSheetPresented) { result in
                            switch result {
                            case .success(let address):
                                self.address = address
                            case .failure: break
                            }
                        }
                }
                Text(address.addressLine1)
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct AddressWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressWidgetView()
    }
}
