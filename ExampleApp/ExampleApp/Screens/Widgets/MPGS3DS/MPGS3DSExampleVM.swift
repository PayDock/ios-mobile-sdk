//
//  MPGS3DSExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import DataPaymentSources
import DataMPGS3ds
import NetworkingLib

@MainActor
class MPGS3dsExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    private let mpgs3dsService: DataMPGS3ds.MPGS3dsService
    private let configManager: ConfigManager

    // MARK: - Properties

    private(set) var token3DS = ""
    @Published var showWebView = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false

    private var apiAccessToken: String {
        return configManager.getGlobalConfig().apiAccessToken
    }

    // MARK: - Initialisation

    init(paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         mpgs3dsService: DataMPGS3ds.MPGS3dsService = DataMPGS3ds.MPGS3dsServiceImpl(),
         configManager: ConfigManager = ConfigManager.shared) {
        self.paymentSourcesService = paymentSourcesService
        self.mpgs3dsService = mpgs3dsService
        self.configManager = configManager
        super.init()
    }

    // MARK: - Config

    func getAppearance(isDarkMode: Bool) -> ThreeDSWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .mpgs3ds,
            isDarkMode: isDarkMode,
            as: ThreeDSWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ThreeDSWidgetAppearance()
    }

    // MARK: - Tokenisation

    func tokeniseCardDetails() {
        isLoading = true
        Task {
            let req = DataPaymentSources.CreatePaymentSourceTokenReq(
                gatewayId: ProjectEnvironment.shared.getMPGSTestGatewayId(),
                cardNumber: "5123450000000008",
                cardName: "Carlie Kuvalis",
                expireMonth: "08",
                expireYear: "29",
                cardCcv: "123",
                storeCcv: true)

            do {
                let token = try await paymentSourcesService.createToken(tokeniseCardDetailsReq: req, widgetAccessToken: self.apiAccessToken)
                create3dsToken(cardToken: token)
            } catch {
                alertMessage = "Error tokenising card details!"
                isLoading = false
                showAlert = true
            }
        }
    }

    private func create3dsToken(cardToken: String) {
        Task {
            let req = DataMPGS3ds.MPGS3dsReq(amount: configManager.getGlobalConfig().totalAmount,
                                             currency: configManager.getGlobalConfig().currency,
                                             threeDS: .init(browserDetails: .init()),
                                             token: cardToken)
            do {
                let token3DS = try await mpgs3dsService.createMPGS3dsToken(request: req, apiAccessToken: self.apiAccessToken)
                self.isLoading = false
                self.token3DS = token3DS ?? ""
                self.showWebView = true
            } catch {
                self.isLoading = false
                self.showWebView = false
                self.alertMessage = "Error tokenising card details!"
                self.showAlert = true
            }
        }
    }

    // MARK: - Handle Callback

    func handle3dsEvent(_ event: MPGS3dsResult) {
        switch event.event {
        case .chargeAuth: break
        case .additionalDataCollectSuccess: break
        case .chargeAuthReject:
            self.showWebView = false
            alertMessage = "3DS auth rejected!"

        case .additionalDataCollectReject:
            self.showWebView = false
            alertMessage = "3DS additional data rejected!"

        case .chargeAuthCancelled:
            self.showWebView = false
            alertMessage = "3DS cancelled!"

        case .chargeAuthSuccess:
            self.showWebView = false
            alertMessage = event.charge3dsId
        }
    }

    func handleFailure(error: MPGS3dsError) {
        showWebView = false
        alertMessage = error.customMessage
        showAlert = true
    }
}
