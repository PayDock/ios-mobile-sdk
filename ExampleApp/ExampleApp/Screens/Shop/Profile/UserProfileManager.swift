//
//  UserProfileManager.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation
import Combine

struct CustomerInfo: Codable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String?
}

class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()

    @Published var profile: UserProfile = UserProfile()
    @Published var isCustomerLinked = false
    @Published var linkedCustomerInfo: CustomerInfo?

    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    private let customerLinkKey = "linkedCustomerInfo"
    private let customerLinkedStatusKey = "isCustomerLinked"

    private init() {
        loadProfile()
        loadCustomerLinkStatus()
    }

    // MARK: - Profile Management

    func updateProfile(firstName: String? = nil, lastName: String? = nil, email: String? = nil, phone: String? = nil) {
        if let firstName = firstName {
            profile.firstName = firstName
        }
        if let lastName = lastName {
            profile.lastName = lastName
        }
        if let email = email {
            profile.email = email
        }
        if let phone = phone {
            profile.phone = phone
        }
        saveProfile()
    }

    func clearProfile() {
        profile = UserProfile()
        saveProfile()
    }

    // MARK: - Customer Linking Management

    func linkCustomer(customerInfo: CustomerInfo) {
        linkedCustomerInfo = customerInfo
        isCustomerLinked = true
        saveCustomerLinkStatus()
    }

    func unlinkCustomer() {
        isCustomerLinked = false
        linkedCustomerInfo = nil
        saveCustomerLinkStatus()
    }

    func clearAllData() {
        clearProfile()
        unlinkCustomer()
    }

    // MARK: - Address Management

    func addAddress(_ address: SavedAddress) {
        // If this is the first address, make it default
        var newAddress = address
        if profile.savedAddresses.isEmpty {
            newAddress.isDefault = true
            profile.defaultAddressId = newAddress.id
        }

        // If setting as default, remove default from others
        if newAddress.isDefault {
            profile.savedAddresses = profile.savedAddresses.map { addr in
                var updatedAddr = addr
                updatedAddr.isDefault = false
                return updatedAddr
            }
            profile.defaultAddressId = newAddress.id
        }

        profile.savedAddresses.append(newAddress)
        saveProfile()
    }

    func updateAddress(_ address: SavedAddress) {
        if let index = profile.savedAddresses.firstIndex(where: { $0.id == address.id }) {
            let updatedAddress = address

            // If setting as default, remove default from others
            if updatedAddress.isDefault {
                profile.savedAddresses = profile.savedAddresses.map { addr in
                    var addr = addr
                    if addr.id != updatedAddress.id {
                        addr.isDefault = false
                    }
                    return addr
                }
                profile.defaultAddressId = updatedAddress.id
            }

            profile.savedAddresses[index] = updatedAddress
            saveProfile()
        }
    }

    func deleteAddress(_ address: SavedAddress) {
        profile.savedAddresses.removeAll { $0.id == address.id }

        // If this was the default address, set a new default if there are other addresses
        if profile.defaultAddressId == address.id {
            if let firstAddress = profile.savedAddresses.first {
                profile.defaultAddressId = firstAddress.id
                setAddressAsDefault(firstAddress)
            } else {
                profile.defaultAddressId = nil
            }
        }

        saveProfile()
    }

    func setAddressAsDefault(_ address: SavedAddress) {
        // Remove default from all addresses
        profile.savedAddresses = profile.savedAddresses.map { addr in
            var updatedAddr = addr
            updatedAddr.isDefault = (addr.id == address.id)
            return updatedAddr
        }

        profile.defaultAddressId = address.id
        saveProfile()
    }

    func getAddressById(_ id: String) -> SavedAddress? {
        return profile.savedAddresses.first { $0.id == id }
    }

    // MARK: - Persistence

    private func saveProfile() {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: profileKey)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    private func loadProfile() {
        guard let data = userDefaults.data(forKey: profileKey) else {
            // Load sample data for demo purposes
            loadSampleProfile()
            return
        }

        do {
            profile = try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("Failed to load profile: \(error)")
            loadSampleProfile()
        }
    }

    private func loadSampleProfile() {
        // Load sample profile data for demo
        let sampleAddress = SavedAddress(
            label: "Home",
            firstName: "John",
            lastName: "Doe",
            addressLine1: "123 Demo Street",
            addressLine2: "Apt 4B",
            city: "Sydney",
            state: "NSW",
            postalCode: "2000",
            country: "Australia",
            isDefault: true
        )

        profile = UserProfile(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+61412345678",
            savedAddresses: [sampleAddress],
            defaultAddressId: sampleAddress.id
        )

        saveProfile()
    }

    // MARK: - Checkout Helper Methods

    // swiftlint:disable:next large_tuple
    func populateCheckoutFromProfile() -> (firstName: String, lastName: String, email: String, phone: String, address: SavedAddress?) {
        return (
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            phone: profile.phone,
            address: profile.defaultAddress
        )
    }

    func saveCheckoutDataToProfile(firstName: String, lastName: String, email: String, phone: String) {
        updateProfile(firstName: firstName, lastName: lastName, email: email, phone: phone)
    }

    // MARK: - Customer Link Persistence

    private func saveCustomerLinkStatus() {
        userDefaults.set(isCustomerLinked, forKey: customerLinkedStatusKey)

        if let customerInfo = linkedCustomerInfo {
            do {
                let data = try JSONEncoder().encode(customerInfo)
                userDefaults.set(data, forKey: customerLinkKey)
            } catch {
                print("Failed to save customer info: \(error)")
            }
        } else {
            userDefaults.removeObject(forKey: customerLinkKey)
        }
    }

    private func loadCustomerLinkStatus() {
        // Load the linked status
        isCustomerLinked = userDefaults.bool(forKey: customerLinkedStatusKey)

        // Load the customer info if it exists
        if let data = userDefaults.data(forKey: customerLinkKey) {
            do {
                linkedCustomerInfo = try JSONDecoder().decode(CustomerInfo.self, from: data)
            } catch {
                print("Failed to load customer info: \(error)")
                // If we can't load the info, reset the status
                isCustomerLinked = false
                linkedCustomerInfo = nil
            }
        }
    }
}
