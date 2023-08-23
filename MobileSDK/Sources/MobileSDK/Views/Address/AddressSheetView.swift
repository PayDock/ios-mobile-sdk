//
//  AddressSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

public struct AddressSheetView: View {

    @Binding var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            AddressView()
        }
    }
}

struct AddressSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSheetView(isPresented: .constant(true))
    }
}
