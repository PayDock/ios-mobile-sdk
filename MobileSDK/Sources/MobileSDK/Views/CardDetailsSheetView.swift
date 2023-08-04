//
//  CardDetailsSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.08.2023..
//

import SwiftUI

public struct CardDetailsSheetView: View {
    
    @Binding var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            CardDetailsView()
        }
    }
}

struct CardDetailsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsSheetView(isPresented: .constant(true))
    }
}
