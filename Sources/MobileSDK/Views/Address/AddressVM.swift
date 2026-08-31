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
    let appearance: AddressWidgetAppearance

    // MARK: - Properties

    @Published var addressSearchSuggestions: [String] = [""]
    @Published var countrySearchSuggestions: [String] = [""]
    @Published var isDisabled = false // not used currently as there's no need for ViewState
    var mkLocalSearchCompletions: [MKLocalSearchCompletion] = []
    var anyCancellable: AnyCancellable? // Required to allow updating the view from nested observable objects - SwiftUI quirk

    var numberOfValidationErrors: Int {
        addressFormManager.numberOfValidationFailures
    }
    var firstTextFieldWithError: AddressFormManager.AddressFocusable? {
        addressFormManager.firstFieldWithError
    }

    // MARK: - Completion Handlers

    private weak var eventDelegate: WidgetEventDelegate?
    private let completion: (Address) -> Void

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

    var countrySearchBinding: Binding<String> {
        Binding(
            get: {
                self.addressFormManager.countrySearchText
            }, set: {
                self.addressFormManager.countrySearchText = $0
                self.addressFormManager.countryText = $0
                self.searchCountry($0)
            }
        )
    }

    // MARK: - Initialisation

    init(config: AddressWidgetConfig,
         appearance: AddressWidgetAppearance,
         eventDelegate: WidgetEventDelegate?,
         addressFormManager: AddressFormManager = AddressFormManager(),
         localSearchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter(),
         completion: @escaping (Address) -> Void) {
        self.config = config
        self.appearance = appearance
        self.eventDelegate = eventDelegate
        self.addressFormManager = addressFormManager
        self.localSearchCompleter = localSearchCompleter
        self.completion = completion

        super.init()
        setup()
    }

    private func setup() {
        localSearchCompleter.delegate = self

        anyCancellable = addressFormManager.objectWillChange.sink { [weak self] _ in
            // Defer to avoid publishing during view updates
            Task {
                self?.objectWillChange.send()
            }
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

            if let coordinate = coordinateK {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    // CLGeocoder's completion isn't guaranteed to run on the main actor, so the Task
                    // must explicitly hop onto it before touching `self`'s main-actor-isolated state.
                    Task { @MainActor in
                        self?.addressFormManager.updateFormWith(reversedGeoLocation: reversedGeoLocation)
                        self?.countrySearchBinding.wrappedValue = reversedGeoLocation.country
                    }
                }
            }
        }
    }

    // MARK: - Country search

    func searchCountry(_ searchableText: String) {
        guard !searchableText.isEmpty else {
            addressFormManager.showCountrySearchPopup = false
            countrySearchSuggestions = [""]
            return
        }

        let filteredCountries = addressFormManager.getCountryList().filter { country in
            country.lowercased().contains(searchableText.lowercased())
        }

        countrySearchSuggestions = Array(filteredCountries.prefix(4))

        if addressFormManager.currentTextField == .country && !addressFormManager.countrySearchText.isEmpty {
            addressFormManager.showCountrySearchPopup = true
        }
    }

    func handleTapOnCountryOptionAt(index: Int?) {
        guard let index = index, index < countrySearchSuggestions.count else { return }

        let selectedCountry = countrySearchSuggestions[index]
        addressFormManager.countrySearchText = selectedCountry
        addressFormManager.countryText = selectedCountry
        addressFormManager.showCountrySearchPopup = false
        countrySearchSuggestions = [""]

    }

    // MARK: - Logic

    /// Validates the form and, only when valid, emits the address via `completion`.
    /// Returns whether the form was valid so the widget can drive VoiceOver error feedback.
    @discardableResult
    func saveAddress() -> Bool {
        addressFormManager.setEditingTextField(focusedField: nil)
        addressFormManager.endEditing()
        addressFormManager.addressSearchText = ""

        guard addressFormManager.validateForm() else { return false }

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
        return true
    }

    func updateAddress() {
        addressFormManager.updateFormWith(address: config.address)
    }

    func expandAddressForm() {
        addressFormManager.isAddressFormExpanded = true
    }

    // MARK: - Validation

    func isActionButtonDisabled() -> Bool {
        if config.activePrimaryButton {
            return false
        }
        return !addressFormManager.isFormValid()
    }

    // MARK: - Analytics Handling

    func handleExpandAddressFormTapAnalytics() {
        let event = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "ManualEntryButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }

    func handleSaveAddresTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "SaveButton", action: .click, text: appearance.actionButton.text))
        )
        eventDelegate?.widgetEvent(event: event)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressVM: MKLocalSearchCompleterDelegate {

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            mkLocalSearchCompletions = completer.results.prefix(4).map { $0 }
            addressSearchSuggestions = mkLocalSearchCompletions.map { "\($0.title), \($0.subtitle)"}
            if addressFormManager.currentTextField == .searchAddress  && !addressFormManager.addressSearchText.isEmpty {
                addressFormManager.showAddressSearchPopup = true
            }
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // No need to handle errors for now
    }
}
