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

    @Published var addressSearchSuggestions: Array<String> = [""]
    var mkLocalSearchCompletions: Array<MKLocalSearchCompletion> = []

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

    // MARK: - Address Search

    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
        localSearchCompleter.queryFragment = searchableText
    }

    func reverseGeoForOptionAt(index: Int?) {
        guard let index = index else { return }

        let location = mkLocalSearchCompletions[index]

        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
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
                    print(reversedGeoLocation)
                    //             address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
                    //             city = "\(reversedGeoLocation.city)"
                    //             state = "\(reversedGeoLocation.state)"
                    //             zip = "\(reversedGeoLocation.zipCode)"
                    //             mapSearch.searchTerm = address
                    //             isFocused = false
                }
            }
        }
    }

}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressVM: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            mkLocalSearchCompletions = completer.results.prefix(5).map { $0 }
            addressSearchSuggestions = mkLocalSearchCompletions.map { "\($0.title), \($0.subtitle)"}
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // No need to handle errors for now
    }

}
