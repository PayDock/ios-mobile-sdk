//
//  ProductService.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 01.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

class ProductService {
    static let shared = ProductService()

    private init() {}

    // swiftlint:disable:next function_body_length
    func getAllProducts() -> [Product] {
        return [
            // Electronics
            Product(
                id: "1",
                name: "Laptop",
                description: "14″ Intel 2 in 1 Laptop with touch screen and 360° flexibility",
                price: 3299.00,
                imageName: "laptop",
                category: .electronics
            ),
            Product(
                id: "2",
                name: "Smartphone",
                description: "512 GB｜12 GB｜Green - Latest flagship smartphone",
                price: 2199.00,
                imageName: "smartphone",
                category: .electronics
            ),
            Product(
                id: "3",
                name: "Wireless Headphones",
                description: "Premium noise-cancelling wireless headphones with 30-hour battery",
                price: 349.99,
                imageName: "headphones",
                category: .electronics
            ),
            Product(
                id: "4",
                name: "Smart Watch",
                description: "Fitness tracking smartwatch with heart rate monitor and GPS",
                price: 299.99,
                imageName: "smartwatch",
                category: .electronics
            ),
            Product(
                id: "5",
                name: "Bluetooth Speaker",
                description: "Portable waterproof speaker with 360° sound and 12-hour battery",
                price: 129.99,
                imageName: "bluetooth-speaker",
                category: .electronics
            ),
            Product(
                id: "6",
                name: "Tablet Pro",
                description: "11-inch tablet with stylus support and all-day battery life",
                price: 899.99,
                imageName: "tablet",
                category: .electronics
            ),

            // Clothing
            Product(
                id: "c1",
                name: "Premium Cotton T-Shirt",
                description: "Soft organic cotton tee with modern fit and sustainable materials",
                price: 29.99,
                imageName: "cotton-tshirt",
                category: .clothing
            ),
            Product(
                id: "c2",
                name: "Denim Jacket",
                description: "Classic blue denim jacket with vintage wash and comfortable fit",
                price: 89.99,
                imageName: "denim-jacket",
                category: .clothing
            ),
            Product(
                id: "c3",
                name: "Wool Sweater",
                description: "Cozy merino wool sweater perfect for cool weather and layering",
                price: 79.99,
                imageName: "wool-sweater",
                category: .clothing
            ),
            Product(
                id: "c4",
                name: "Slim Fit Jeans",
                description: "Comfortable stretch denim with modern slim fit and dark wash",
                price: 69.99,
                imageName: "jeans-pants",
                category: .clothing
            ),
            Product(
                id: "c5",
                name: "Athletic Hoodie",
                description: "Performance hoodie with moisture-wicking fabric and kangaroo pocket",
                price: 59.99,
                imageName: "sport-hoodie",
                category: .clothing
            ),
            Product(
                id: "c6",
                name: "Summer Dress",
                description: "Flowy midi dress in breathable fabric, perfect for warm weather",
                price: 49.99,
                imageName: "dress",
                category: .clothing
            ),
            Product(
                id: "c7",
                name: "Running Shorts",
                description: "Lightweight athletic shorts with built-in compression and pockets",
                price: 34.99,
                imageName: "running-shorts",
                category: .clothing
            ),
            Product(
                id: "c8",
                name: "Winter Coat",
                description: "Insulated winter coat with waterproof shell and removable hood",
                price: 199.99,
                imageName: "winter-coat",
                category: .clothing
            ),

            // Accessories
            Product(
                id: "a1",
                name: "Leather Wallet",
                description: "Genuine leather bifold wallet with RFID blocking and card slots",
                price: 45.99,
                imageName: "wallet",
                category: .accessories
            ),
            Product(
                id: "a2",
                name: "Designer Sunglasses",
                description: "UV protection sunglasses with polarized lenses and metal frame",
                price: 129.99,
                imageName: "sunglasses",
                category: .accessories
            ),
            Product(
                id: "a3",
                name: "Canvas Backpack",
                description: "Durable canvas backpack with laptop compartment and multiple pockets",
                price: 79.99,
                imageName: "backpack",
                category: .accessories
            ),
            Product(
                id: "a4",
                name: "Silk Scarf",
                description: "Luxurious silk scarf with elegant pattern and soft texture",
                price: 39.99,
                imageName: "silk-scarf",
                category: .accessories
            ),
            Product(
                id: "a5",
                name: "Sports Cap",
                description: "Adjustable baseball cap with breathable fabric and curved brim",
                price: 24.99,
                imageName: "cap",
                category: .accessories
            ),
            Product(
                id: "a6",
                name: "Leather Belt",
                description: "Classic leather belt with metal buckle and genuine cowhide",
                price: 35.99,
                imageName: "leather-belt",
                category: .accessories
            ),
            Product(
                id: "a7",
                name: "Wrist Watch",
                description: "Analog watch with leather strap and water-resistant design",
                price: 159.99,
                imageName: "watch",
                category: .accessories
            ),
            Product(
                id: "a8",
                name: "Crossbody Bag",
                description: "Compact crossbody bag with adjustable strap and secure zipper",
                price: 54.99,
                imageName: "crossbody-bag",
                category: .accessories
            ),

            // Home
            Product(
                id: "h1",
                name: "Coffee Maker",
                description: "Programmable drip coffee maker with thermal carafe and auto-brew",
                price: 89.99,
                imageName: "coffee-maker",
                category: .home
            ),
            Product(
                id: "h2",
                name: "Table Lamp",
                description: "Modern LED table lamp with adjustable brightness and USB charging",
                price: 49.99,
                imageName: "table-lamp",
                category: .home
            ),
            Product(
                id: "h3",
                name: "Throw Pillow Set",
                description: "Set of 2 decorative throw pillows with removable covers",
                price: 29.99,
                imageName: "pillows",
                category: .home
            ),
            Product(
                id: "h4",
                name: "Kitchen Scale",
                description: "Digital kitchen scale with precise measurements and LCD display",
                price: 34.99,
                imageName: "scale",
                category: .home
            ),

            // Gift Cards
            Product(
                id: "gc1",
                name: "$25 Gift Card",
                description: "Perfect for any occasion - can be used on any purchase in our store",
                price: 25.00,
                imageName: "gift25",
                category: .giftCards
            ),
            Product(
                id: "gc2",
                name: "$50 Gift Card",
                description: "Perfect for any occasion - can be used on any purchase in our store",
                price: 50.00,
                imageName: "gift50",
                category: .giftCards
            ),
            Product(
                id: "gc3",
                name: "$100 Gift Card",
                description: "Perfect for any occasion - can be used on any purchase in our store",
                price: 100.00,
                imageName: "gift100",
                category: .giftCards
            )
        ]
    }

    func getProductsByCategory(_ category: ProductCategory) -> [Product] {
        return getAllProducts().filter { $0.category == category }
    }

    func getFeaturedProducts() -> [Product] {
        return Array(getAllProducts().filter { $0.category != .giftCards }.prefix(6))
    }

    func getGiftCardProducts() -> [Product] {
        return getAllProducts().filter { $0.category == .giftCards }
    }

    func getClothingProducts() -> [Product] {
        return getAllProducts().filter { $0.category == .clothing }
    }

    func getAccessoryProducts() -> [Product] {
        return getAllProducts().filter { $0.category == .accessories }
    }

    func getHomeProducts() -> [Product] {
        return getAllProducts().filter { $0.category == .home }
    }
}
