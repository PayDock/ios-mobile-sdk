//
//  CardDetailsView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 25.07.2023..
//

import SwiftUI
import MobileSDK

struct CardDetailsView: View {
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
                    CardDetailsSheetView(isPresented: $isSheetPresented)
                }

            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView()
    }
}
