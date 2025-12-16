//
//  ConfigPickerView.swift
//  ExampleApp
//

import SwiftUI
import MobileSDK
import PayPalWebPayments

struct ConfigPickerView: View {

    @EnvironmentObject var configVM: ConfigVM
    @State private var selectedIndex: Int = 0

    let selectedWidget: ConfigWidgetsEnum
    let configKey: ConfigKeys
    let title: String

    private var options: [String] {
        switch configKey {
        case .fundingSource:
            return ["PayPal", "Pay Later", "PayPal Credit"]
        case .environment:
            return ["Production", "Sandbox", "Staging"]
        default:
            return []
        }
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
            if let config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
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
        default:
            break
        }
    }

    private func updateConfiguration(with index: Int) {
        switch selectedWidget {
        case .paypal:
            if var config = configVM.getConfiguration(for: .paypal, as: PayPalWidgetConfig.self) {
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
                default:
                    break
                }
                configVM.updateConfiguration(for: .paypal, with: config)
            }
        default:
            break
        }
    }

    private func resetToDefault() {
        switch selectedWidget {
        case .paypal:
            switch configKey {
            case .fundingSource:
                selectedIndex = 0 // PayPal
            default:
                break
            }
        default:
            break
        }
        updateConfiguration(with: selectedIndex)
    }
}
