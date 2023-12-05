//
//  CardDetailsSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct CardDetailsSheetView: View {

    @State private var gatewayId: String
    @Binding var isPresented: Bool
    @Binding var onCompletion: String

    public init(isPresented: Binding<Bool>,
                gatewayId: String,
                onCompletion: Binding<String>) {
        self._isPresented = isPresented
        self.gatewayId = gatewayId
        self._onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            CardDetailsWidget(gatewayId: gatewayId, onCompletion: $onCompletion)
        }
    }
}

struct CardDetailsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsSheetView(isPresented: .constant(true), gatewayId: "a1234", onCompletion: .constant("Asd"))
    }
}
