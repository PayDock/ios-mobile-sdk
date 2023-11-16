//
//  GiftCardSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.11.2023..
//

import SwiftUI

public struct GiftCardSheetView: View {

    // MARK: - Properties

    @Binding var isPresented: Bool
    @Binding var onCompletion: String?
    @Binding var onFailure: Error?

    // MARK: - Initialisation

    public init(isPresented: Binding<Bool>,
                onCompletion: Binding<String?>,
                onFailure: Binding<Error?>) {
        self._isPresented = isPresented
        self._onCompletion = onCompletion
        self._onFailure = onFailure
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            GiftCardView(onCompletion: $onCompletion, onFailure: $onFailure)
        }
    }
}

struct GiftCardSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GiftCardSheetView(
            isPresented: .constant(true),
            onCompletion: .constant(""), onFailure: .constant(.none))
    }
}
