//
//  AddressVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import Foundation

class AddressVM: ObservableObject {

    // MARK: - Dependencies

    var addressFormManager: AddressFormManager

    // MARK: - Initialisation

    init(addressFormManager: AddressFormManager = AddressFormManager()) {
        self.addressFormManager = addressFormManager
    }

    var text = ""
    var isValid = true

}
