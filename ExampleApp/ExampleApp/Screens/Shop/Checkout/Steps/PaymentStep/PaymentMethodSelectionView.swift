//
//  PaymentMethodSelectionView.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

struct PaymentMethodSelectionView: View {
    let selectedMethod: PaymentMethod?
    let onMethodSelected: (PaymentMethod) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                PaymentMethodRow(
                    method: method,
                    isSelected: selectedMethod == method
                ) {
                    onMethodSelected(method)
                }
            }
        }
    }
}
