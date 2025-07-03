//
//  AddressVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 21.08.2023..
//

import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class AddressVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    var addressFormManager: AddressFormManager
    private let localSearchCompleter: MKLocalSearchCompleter
    private let config: AddressWidgetConfig

    // MARK: - Properties

    @Published var addressSearchSuggestions: Array<String> = [""]
    @Published var isDisabled = false
    var mkLocalSearchCompletions: Array<MKLocalSearchCompletion> = []
    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk
    let completion: (Address) -> Void

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

    init(config: AddressWidgetConfig,
         addressFormManager: AddressFormManager = AddressFormManager(),
         localSearchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter(),
         completion: @escaping (Address) -> Void) {
        self.config = config
        self.addressFormManager = addressFormManager
        self.localSearchCompleter = localSearchCompleter
        self.completion = completion

        super.init()
        setup()
    }

    private func setup() {
        localSearchCompleter.delegate = self

        anyCancellable = addressFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Address Search

    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else {
            addressFormManager.showAddressSearchPopup = false
            return
        }
        localSearchCompleter.queryFragment = searchableText
    }

    func handleTapOnOptionAt(index: Int?) {
        guard let index = index else { return }

        addressFormManager.isAddressFormExpanded = true
        addressFormManager.addressSearchText = ""
        addressFormManager.showAddressSearchPopup = false

        addressSearchSuggestions = [""]
        reverseGeoForOptionAt(index: index)
    }

    private func reverseGeoForOptionAt(index: Int) {
        let location = mkLocalSearchCompletions[index]

        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK: CLLocationCoordinate2D?
        search.start { [weak self] (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }

            if let c = coordinateK {
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    self?.addressFormManager.updateFormWith(reversedGeoLocation: reversedGeoLocation)
                }
            }
        }
    }

    // MARK: - Logic

    func saveAddress() {
        addressFormManager.setEditingTextField(focusedField: nil)
        addressFormManager.endEditing()
        addressFormManager.addressSearchText = ""

        addressFormManager.validateAllTextFields()
        let address = Address(
            firstName: addressFormManager.firstNameText,
            lastName: addressFormManager.lastNameText,
            addressLine1: addressFormManager.addressLine1Text,
            addressLine2: addressFormManager.addressLine2Text,
            city: addressFormManager.cityText,
            state: addressFormManager.stateText,
            postcode: addressFormManager.postcodeText,
            country: addressFormManager.countryText)

        completion(address)
    }
    
    func updateAddress() {
        addressFormManager.updateFormWith(address: config.address)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressVM: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        mkLocalSearchCompletions = completer.results.prefix(4).map { $0 }
        addressSearchSuggestions = mkLocalSearchCompletions.map { "\($0.title), \($0.subtitle)"}
        if addressFormManager.currentTextField == .searchAddress  && !addressFormManager.addressSearchText.isEmpty {
            addressFormManager.showAddressSearchPopup = true
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // No need to handle errors for now
    }

}
