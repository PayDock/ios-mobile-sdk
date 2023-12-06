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

    @StateObject private var viewModel = GiftCardWidgetVM()
    @State var isSheetPresented = false
    @State var text = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                        Spacer()
                        Button("Launch Gift Card sheet") {
                            isSheetPresented = true
                        }
                        .padding()
                        EmptyView()
                        GiftCardSheetView(
                            isPresented: $isSheetPresented,
                            completion: { result in
                                switch result {
                                case .success(let text): self.text = text
                                case .failure(let error): self.text = error.localizedDescription
                                }
                            })
                        Spacer()
                }
                Text(text)

            }
            .background(Color(hex: "#EAE0D7"))
        }
    }
}

struct GiftCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardWidgetView()
    }
}

