//
//  AddressSheetView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

public struct AddressSheetView: View {

    @Binding var isPresented: Bool
    @Binding var onCompletion: Address

    public init(isPresented: Binding<Bool>,
                onCompletion: Binding<Address>) {
        self._isPresented = isPresented
        self._onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            Text("")
        }
        .bottomSheet(isPresented: $isPresented) {
            AddressView(onCompletion: $onCompletion)
        }
    }
}

struct AddressSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSheetView(
            isPresented: .constant(true),
            onCompletion: .constant(
                Address(
                    firstName: "John",
                    lastName: "Smith",
                    addressLine1: "John's Address 22",
                    addressLine2: "",
                    city: "Johnstown",
                    state: "Johnstate",
                    postcode: "10000",
                    country: "Johnnystan")))
    }
}
