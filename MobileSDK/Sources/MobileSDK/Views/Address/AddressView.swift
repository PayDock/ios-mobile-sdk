//
//  AddressView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

struct AddressView: View {

    @State var viewModel = AddressVM()

    var body: some View {
        VStack {
            AutocompleteTextField(
                text: $viewModel.text,
                title: "Select countries",
                placeholder: "",
                errorMessage: .constant(""),
                editing: .constant(true),
                valid: .constant(true),
                hasOptions: true,
                options: ["option 1", "option 2"])

        }
        .frame(height: 200)
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView()
    }
}
