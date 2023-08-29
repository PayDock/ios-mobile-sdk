//
//  AddressVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 21.08.2023..
//

import Foundation
import SwiftUI
import MapKit
import Combine

class AddressVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    var addressFormManager: AddressFormManager
    private let localSearchCompleter: MKLocalSearchCompleter

    // MARK: - Properties

    @Published var addressSearchSuggestions: Array<String> = [""]
    var mkLocalSearchCompletions: Array<MKLocalSearchCompletion> = []
    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

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

        anyCancellable = addressFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Address Search

    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
        localSearchCompleter.queryFragment = searchableText
    }

    func handleTapOnOptionAt(index: Int?) {
        guard let index = index else { return }

        addressFormManager.isAddressFormExpanded = true
        addressFormManager.addressSearchText = ""
        addressFormManager.showAddressSearchPopup = false
        addressFormManager.setEditingTextField(focusedField: nil)

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
        let address = Address(
            firstName: addressFormManager.firstNameText,
            lastName: addressFormManager.lastNameText,
            addressLine1: addressFormManager.addressLine1Text,
            addressLine2: addressFormManager.addressLine2Text,
            city: addressFormManager.cityText,
            state: addressFormManager.stateText,
            postcode: addressFormManager.postcodeText,
            country: addressFormManager.countryText)

        
    }

}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressVM: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            mkLocalSearchCompletions = completer.results.prefix(4).map { $0 }
            addressSearchSuggestions = mkLocalSearchCompletions.map { "\($0.title), \($0.subtitle)"}
            addressFormManager.showAddressSearchPopup = true
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // No need to handle errors for now
    }

}
