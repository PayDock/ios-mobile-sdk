//
//  PayPalButtonWrapper.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 19.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI
import UIKit
import PaymentButtons

class FullWidthPayPalButtonWrapper: UIView {
    private(set) var paypalButton: PayPalButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupButton(_ button: PayPalButton) {
        // Remove existing button if any
        paypalButton?.removeFromSuperview()

        paypalButton = button
        addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Force the button to update its layout when the container changes
        paypalButton?.setNeedsLayout()
        paypalButton?.layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize {
        guard let button = paypalButton else {
            return CGSize(width: UIView.noIntrinsicMetric, height: 44)
        }

        let buttonSize = button.intrinsicContentSize

        // Return flexible width but preserve the button's natural height
        return CGSize(width: UIView.noIntrinsicMetric, height: buttonSize.height
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let button = paypalButton else {
            return CGSize(width: size.width, height: 44)
        }

        let buttonSize = button.sizeThatFits(size)

        // Use the available width but preserve button's preferred height
        return CGSize(width: size.width, height: buttonSize.height
        )
    }
}
