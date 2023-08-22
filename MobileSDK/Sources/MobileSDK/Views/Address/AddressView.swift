//
//  AddressView.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import SwiftUI

struct AddressView: View {

    @StateObject var viewModel = AddressVM()

    @FocusState private var textFieldInFocus: AddressFormManager.AddressFocusable?

    var body: some View {
        VStack {
            AutocompleteTextField(
                text: $viewModel.addressFormManager.addressSearchErrorText,
                title: viewModel.addressFormManager.addressSearchErrorTitle,
                placeholder: viewModel.addressFormManager.addressSearchErrorPlaceholder,
                errorMessage: $viewModel.addressFormManager.addressSearchError,
                editing: $viewModel.addressFormManager.editingAddressSearch,
                valid: $viewModel.addressFormManager.addressSearchErrorValid,
                showPopup: $viewModel.addressFormManager.showAddressSearchPopup,
                options: ["option 1", "option 2"])
            .focused($textFieldInFocus, equals: .searchAddress)
            .onTapGesture {
                self.textFieldInFocus = .searchAddress
                viewModel.addressFormManager.setEditingTextField(focusedField: .searchAddress)
            }

        }
        .frame(height: 200)
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView()
    }
}
