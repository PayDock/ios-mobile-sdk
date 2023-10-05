//
//  ApplePayWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 04.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct ApplePayWidgetView: View {
    @State var isSheetPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                    Button("Launch Apple Pay sheet") {
                        isSheetPresented = true
                    }
                    .padding()
                    Spacer()
                }
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct ApplePayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayWidgetView()
    }
}
