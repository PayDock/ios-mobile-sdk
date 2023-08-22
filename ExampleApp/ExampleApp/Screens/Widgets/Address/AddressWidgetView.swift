//
//  AddressWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI
import MobileSDK

struct AddressWidgetView: View {
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
                    AddressSheetView(
                        isPresented: $isSheetPresented)
                }
                Text("")
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
