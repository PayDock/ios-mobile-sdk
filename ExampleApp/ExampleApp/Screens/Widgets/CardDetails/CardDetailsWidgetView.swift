//
//  CardDetailsWidgetView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI
import MobileSDK

struct CardDetailsWidgetView: View {
    @State var cardToken: String = ""
    @State var isSheetPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Spacer()
                    Button("Launch card sheet") {
                        isSheetPresented = true
                    }
                    .padding()
                    Spacer()
                    CardDetailsSheetView(
                        isPresented: $isSheetPresented,
                        gatewayId: "5cbede1f151b842653e987be",
                        onCompletion: $cardToken)
                }
                Text(cardToken)
            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsWidgetView()
    }
}
