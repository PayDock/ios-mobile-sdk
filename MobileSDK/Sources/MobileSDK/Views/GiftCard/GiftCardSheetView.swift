//
//  GiftCardSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.11.2023..
//

import SwiftUI

public struct GiftCardSheetView: View {

    @Binding var isPresented: Bool
    @Binding var onCompletion: String

    public init(isPresented: Binding<Bool>,
                onCompletion: Binding<String>) {
        self._isPresented = isPresented
        self._onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            // TODO: - Add proper data passing after endpoints are implemented
            GiftCardView(gatewayId: "", onCompletion: $onCompletion)
        }
    }
}

struct GiftCardSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardSheetView(
            isPresented: .constant(true),
            onCompletion: .constant(""))
    }
}
