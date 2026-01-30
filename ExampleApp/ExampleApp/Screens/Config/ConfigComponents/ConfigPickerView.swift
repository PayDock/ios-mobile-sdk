//
//  ConfigPickerView.swift
//  ExampleApp

import SwiftUI
import MobileSDK
import PayPalWebPayments

struct ConfigPickerView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var selectedIndex: Int = 0

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys?
    let title: String

    init(selectedWidget: ConfigWidgetsEnum,
         configKey: ConfigKeys? = nil,
         title: String) {
        self.selectedWidget = selectedWidget
        self.configKey = configKey
        self.title = title
    }

    private var options: [String] {
        if let configKey = configKey {
            switch configKey {
            case .fundingSource:
                return ["PayPal", "Pay Later", "PayPal Credit"]
            case .gender:
                return ["male", "female", "other", "prefer_not_to_say"]
            case .shippingType:
                return ["delivery", "pickup"]
            default:
                return []
            }
        }
        return []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionTitleView(title: "Selection")

                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)

                        Picker("Select \(title)", selection: $selectedIndex) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Text(options[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedIndex) { newValue in
                            updateConfiguration(with: newValue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)

                    ResetStyleButton {
                        resetToDefault()
                    }
                }
                .padding(.bottom, 16.0)
                .navigationTitle(title)
            }
            .background(Color(hex: "#EAE0D7"))
        }
        .foregroundColor(.black)
        .onAppear {
            loadCurrentValue()
        }
    }

    private func loadCurrentValue() {
        switch selectedWidget {
        case .paypal:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
                switch configKey {
                case .fundingSource:
                    switch config.fundingSource {
                    case .paypal:
                        selectedIndex = 0
                    case .paylater:
                        selectedIndex = 1
                    case .paypalCredit:
                        selectedIndex = 2
                    @unknown default:
                        selectedIndex = 0
                    }
                default:
                    break
                }
            }
        case .zip:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) {
                switch configKey {
                case .gender:
                    let genderOptions = ["male", "female", "other", "prefer_not_to_say"]
                    if let gender = config.gender,
                       let index = genderOptions.firstIndex(of: gender) {
                        selectedIndex = index
                    } else {
                        selectedIndex = 0
                    }
                case .shippingType:
                    let shippingTypeOptions = ["delivery", "pickup"]
                    if let shippingType = config.shippingType,
                       let index = shippingTypeOptions.firstIndex(of: shippingType) {
                        selectedIndex = index
                    } else {
                        selectedIndex = 0 // default to "delivery"
                    }
                default:
                    break
                }
            }
        default:
            break
        }
    }

    // swiftlint:disable:next function_body_length
    private func updateConfiguration(with index: Int) {
        switch selectedWidget {
        case .paypal:
            if let configKey = configKey,
               var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
                switch configKey {
                case .fundingSource:
                    let fundingSource: PayPalWebCheckoutFundingSource
                    switch index {
                    case 0: fundingSource = .paypal
                    case 1: fundingSource = .paylater
                    case 2: fundingSource = .paypalCredit
                    default: fundingSource = .paypal
                    }
                    config = PayPalWidgetConfig(
                        accessToken: config.accessToken,
                        gatewayId: config.gatewayId,
                        requestShipping: config.requestShipping,
                        fundingSource: fundingSource
                    )
                    configVM.updateConfiguration(for: .paypal, with: config)
                default:
                    break
                }
            }
        case .zip:
            if let configKey = configKey,
               let config = configVM.getConfiguration(for: .zip, as: ZipWidgetConfig.self) {
                let updatedConfig: ZipWidgetConfig

                switch configKey {
                case .gender:
                    let genderOptions = ["male", "female", "other", "prefer_not_to_say"]
                    let selectedGender = index < genderOptions.count ? genderOptions[index] : nil
                    updatedConfig = ZipWidgetConfig(
                        accessToken: config.accessToken,
                        gatewayId: config.gatewayId,
                        amount: config.amount,
                        currency: config.currency,
                        firstName: config.firstName,
                        lastName: config.lastName,
                        email: config.email,
                        phone: config.phone,
                        tokenize: config.tokenize,
                        gender: selectedGender,
                        dateOfBirth: config.dateOfBirth,
                        shippingType: config.shippingType,
                        billing: config.billing,
                        shipping: config.shipping,
                        items: config.items,
                        statistics: config.statistics
                    )
                case .shippingType:
                    let shippingTypeOptions = ["delivery", "pickup"]
                    let selectedShippingType = index < shippingTypeOptions.count ? shippingTypeOptions[index] : nil
                    updatedConfig = ZipWidgetConfig(
                        accessToken: config.accessToken,
                        gatewayId: config.gatewayId,
                        amount: config.amount,
                        currency: config.currency,
                        firstName: config.firstName,
                        lastName: config.lastName,
                        email: config.email,
                        phone: config.phone,
                        tokenize: config.tokenize,
                        gender: config.gender,
                        dateOfBirth: config.dateOfBirth,
                        shippingType: selectedShippingType,
                        billing: config.billing,
                        shipping: config.shipping,
                        items: config.items,
                        statistics: config.statistics
                    )
                default:
                    return
                }
                configVM.updateConfiguration(for: .zip, with: updatedConfig)
            }
        default:
            break
        }
    }

    private func resetToDefault() {
        switch selectedWidget {
        case .paypal:
            if let configKey = configKey {
                switch configKey {
                case .fundingSource:
                    selectedIndex = 0 // PayPal
                default:
                    break
                }
            }
        case .zip:
            if let configKey = configKey {
                switch configKey {
                case .gender:
                    selectedIndex = 0 // male
                case .shippingType:
                    selectedIndex = 0 // delivery
                default:
                    break
                }
            }
        default:
            break
        }
        updateConfiguration(with: selectedIndex)
    }
}
