//
//  AddressVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import Foundation
import SwiftUI
import MapKit

class AddressVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    var addressFormManager: AddressFormManager
    private let localSearchCompleter: MKLocalSearchCompleter

    // MARK: - Properties

    @Published private(set) var results: Array<String> = []

    // MARK: - Custom bindings

    var addressSearchBinding: Binding<String> {
        Binding(
            get: {
                self.addressFormManager.addressSearchText
            }, set: {
                self.addressFormManager.addressSearchText = $0
                self.searchAddress($0)
            }
        )
    }

    // MARK: - Initialisation

    init(addressFormManager: AddressFormManager = AddressFormManager(),
         localSearchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.addressFormManager = addressFormManager
        self.localSearchCompleter = localSearchCompleter

        super.init()
        setup()
    }

    private func setup() {
        localSearchCompleter.delegate = self
    }

    // MARK: - Search

    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
        localSearchCompleter.queryFragment = searchableText
    }

}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressVM: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            let addressesResult = completer.results.prefix(5)
            let addresses = addressesResult.map { "\($0.title), \($0.subtitle)"}
            addressFormManager.addressSearchSuggestions = addresses
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // No need to handle errors for now
    }

}
