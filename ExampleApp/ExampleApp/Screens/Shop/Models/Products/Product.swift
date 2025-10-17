//
//  Product.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: ProductCategory
    var isInStock: Bool = true

    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
}

enum ProductCategory: String, CaseIterable, Codable {
    case electronics = "Electronics"
    case clothing = "Clothing"
    case accessories = "Accessories"
    case home = "Home"
    case giftCards = "Gift Cards"

    var displayName: String {
        return self.rawValue
    }
}

struct CartItem: Identifiable, Codable {
    var id = UUID()
    let product: Product
    var quantity: Int

    var totalPrice: Double {
        return product.price * Double(quantity)
    }

    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
}

enum CartShippingOption: CaseIterable {
    case free
    case express

    var name: String {
        switch self {
        case .free: return "Standard Shipping"
        case .express: return "Express Shipping"
        }
    }

    var price: Double {
        switch self {
        case .free: return 0.0
        case .express: return 2.0
        }
    }

    var formattedPrice: String {
        if price == 0.0 {
            return "Free"
        }
        return String(format: "$%.2f", price)
    }

    var description: String {
        switch self {
        case .free: return "5-7 business days"
        case .express: return "1-2 business days"
        }
    }
}

// MARK: - Gift Card Models

struct GiftCard: Identifiable, Codable {
    var id = UUID()
    let cardNumber: String
    let pin: String
    var balance: Double
    var isValid: Bool = true

    var formattedBalance: String {
        return String(format: "$%.2f", balance)
    }

    var maskedCardNumber: String {
        let last4 = String(cardNumber.suffix(4))
        return "**** **** **** \(last4)"
    }
}

struct AppliedGiftCard: Identifiable, Codable {
    var id = UUID()
    let giftCard: GiftCard
    var appliedAmount: Double

    var formattedAppliedAmount: String {
        return String(format: "$%.2f", appliedAmount)
    }
}

// MARK: - User Profile Models

struct UserProfile: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var savedAddresses: [SavedAddress] = []
    var defaultAddressId: String?

    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var defaultAddress: SavedAddress? {
        return savedAddresses.first { $0.id == defaultAddressId }
    }
}

struct SavedAddress: Identifiable, Codable {
    var id = UUID().uuidString
    var label: String // e.g., "Home", "Work", "Billing"
    var firstName: String = ""
    var lastName: String = ""
    var addressLine1: String = ""
    var addressLine2: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = ""
    var isDefault: Bool = false

    var formattedAddress: String {
        var components: [String] = []

        if !firstName.isEmpty && !lastName.isEmpty {
            components.append("\(firstName) \(lastName)")
        }
        if !addressLine1.isEmpty {
            components.append(addressLine1)
        }
        if !addressLine2.isEmpty {
            components.append(addressLine2)
        }
        if !city.isEmpty && !state.isEmpty {
            components.append("\(city), \(state)")
        } else if !city.isEmpty {
            components.append(city)
        }
        if !postalCode.isEmpty {
            components.append(postalCode)
        }
        if !country.isEmpty {
            components.append(country)
        }

        return components.joined(separator: "\n")
    }

    var isComplete: Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        !addressLine1.isEmpty &&
        !city.isEmpty &&
        !postalCode.isEmpty &&
        !country.isEmpty
    }
}
