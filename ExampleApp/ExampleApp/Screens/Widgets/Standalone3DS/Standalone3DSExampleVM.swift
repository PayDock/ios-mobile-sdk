//
//  Standalone3DSExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import DataPaymentSources
import DataVault
import DataStandalone3ds

@MainActor
class Standalone3DSExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    private let vaultService: DataVault.VaultService
    private let standalone3dsService: DataStandalone3ds.Standalone3dsService
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
         vaultService: DataVault.VaultService = DataVault.VaultServiceImpl(),
         standalone3dsService: DataStandalone3ds.Standalone3dsService = DataStandalone3ds.Standalone3dsServiceImpl(),
         configManager: ConfigManager = .shared) {
        self.paymentSourcesService = paymentSourcesService
        self.vaultService = vaultService
        self.standalone3dsService = standalone3dsService
        self.configManager = configManager
        super.init()
    }

    // MARK: - Config

    func getAppearance(isDarkMode: Bool) -> Standalone3dsWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .standalone3ds,
            isDarkMode: isDarkMode,
            as: Standalone3dsWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? Standalone3dsWidgetAppearance()
    }

    // MARK: - Tokenisation

    func getVaultToken() {
            isLoading = true
            let req = DataPaymentSources.CreatePaymentSourceTokenReq(
                cardNumber: "4100000000005000",
                cardName: "Test Card",
                expireMonth: "09",
                expireYear: "39",
                cardCcv: "100",
                storeCcv: true)
        Task {
            do {
                // First create card token
                let cardToken = try await paymentSourcesService.createToken(tokeniseCardDetailsReq: req, widgetAccessToken: apiAccessToken)
                // Then convert to vault token
                let vaultTokenReq = DataVault.ConvertToVaultTokenReq(token: cardToken, vaultType: "session")
                let vaultToken = try await vaultService.createVaultToken(request: vaultTokenReq, apiAccessToken: apiAccessToken)
                create3dsToken(vaultToken: vaultToken)
            } catch {
                self.isLoading = false
                self.showWebView = false
                self.alertMessage = "Error fetching vault token!"
                self.showAlert = true
            }
        }
    }

    private func create3dsToken(vaultToken: String) {
        Task {
            let request = DataStandalone3ds.Standalone3DSReq(
                amount: configManager.getGlobalConfig().totalAmount,
                currency: configManager.getGlobalConfig().currency,
                reference: UUID().uuidString,
                customer: .init(paymentSource: .init(vaultToken: vaultToken)),
                data: .init(
                    serviceId: ProjectEnvironment.shared.getGPaymentsServiceId() ?? "",
                    authentication: .init(
                        type: "01",
                        date: "2023-06-01T13:00:00.521Z",
                        version: "2.2.0",
                        customer: .init(
                            created: "2023-05-31T13:06:05.521Z",
                            updated: "2023-05-31T13:06:05.521Z",
                            credsUpdated: "2023-05-31T13:06:05.521Z",
                            suspicious: false,
                            source: .init(
                                created: "2023-05-31T13:06:05.521Z",
                                attempts: ["2023-05-31T13:06:05.521Z"],
                                cardType: "02"
                            )
                        )
                    )
                )
            )
            do {
                let token3DS = try await standalone3dsService.createStandalone3DSToken(request: request, apiAccessToken: apiAccessToken)
                self.isLoading = false
                self.token3DS = token3DS ?? ""
                self.showWebView = true

            } catch {
                self.isLoading = false
                self.showWebView = false
                self.alertMessage = "3DS failed!"
                self.showAlert = true
            }
        }
    }

    // MARK: - Handle Callbacks

    func handle3dsEvent(_ event: Standalone3DSResult) {
        // Delay for UX purposes - allow WebView to close before showing alert
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            switch event.event {
            case .chargeAuthChallenge: break
            case .chargeAuthDecoupled:
                self.showWebView = false
                self.alertMessage = "3DS Auth Decoupled!"
                self.showAlert = true

            case .chargeAuthInfo:
                self.showWebView = false
                self.alertMessage = "3DS Auth Info!"
                self.showAlert = true

            case .chargeAuthSuccess:
                self.showWebView = false
                self.alertMessage = event.charge3dsId
                self.showAlert = true

            case .chargeAuthReject:
                self.showWebView = false
                self.alertMessage = "3DS Auth rejected!"
                self.showAlert = true

            case .chargeError:
                self.showWebView = false
                self.alertMessage = "3DS failed!"
                self.showAlert = true
            }
        }
    }

    func handleFailure(error: Standalone3DSError) {
        showWebView = false
        alertMessage = error.customMessage
        showAlert = true
    }
}
