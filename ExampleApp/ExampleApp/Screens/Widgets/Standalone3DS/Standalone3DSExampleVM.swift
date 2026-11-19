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

/// Presentation phases of the Widgets > Standalone 3DS demo sheet.
enum Standalone3DSDemoPhase: Equatable {
    /// Card, vault and 3DS tokens are being created.
    case preparing
    /// The widget is mounted and running (fingerprint / processing).
    case verifying
    /// The issuer requires a challenge; the bank's page is still loading.
    case challengeLoading
    /// The bank's challenge page is visible.
    case challenge
    /// The shopper finished the challenge; the result is being confirmed.
    case finalizing
    /// The shopper must approve the payment out-of-band.
    case decoupled(description: String?)
    case success
    /// The bank declined the authentication (`chargeAuthReject`).
    case declined
    /// An error interrupted the authentication (`chargeError`, `Standalone3DSError` or token creation).
    case failed(detail: String?)

    var isTerminal: Bool {
        switch self {
        case .success, .declined, .failed: return true
        default: return false
        }
    }
}

/// Which authentication path the issuer took.
enum Standalone3DSDemoFlow: String {
    case frictionless = "Frictionless"
    case challenge = "Challenge"
    case decoupled = "Decoupled"

    /// The flow the SDK reported on the final result; frictionless when it reported none.
    init(_ flow: Standalone3DSResult.AuthenticationFlow?) {
        switch flow {
        case .challenge: self = .challenge
        case .decoupled: self = .decoupled
        case .frictionless, nil: self = .frictionless
        }
    }
}

/// Summary of a successful authentication, shown in the success details card.
struct Standalone3DSDemoOutcome: Equatable {
    let status: String?
    let resultDescription: String?
    let charge3dsId: String
    let flow: Standalone3DSDemoFlow
    let amount: String
    let cardLast4: String?
}

@MainActor
class Standalone3DSExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    private let vaultService: DataVault.VaultService
    private let standalone3dsService: DataStandalone3ds.Standalone3dsService
    private let configManager: ConfigManager

    // MARK: - Properties

    @Published private(set) var token3DS = ""
    @Published var isSheetPresented = false
    @Published private(set) var phase: Standalone3DSDemoPhase = .preparing
    /// Set once `verifying` has taken longer than `slowAfter`.
    @Published private(set) var isSlow = false
    /// Set once a challenge was announced, so `finalizing` keeps the expanded sheet.
    @Published private(set) var challengeMounted = false
    @Published private(set) var outcome: Standalone3DSDemoOutcome?

    /// Suppresses the SDK's own loader — the sheet's phase overlay is the single loader.
    let loadingDelegate = SilentWidgetLoadingDelegate()

    private var attempt = 0
    private var cardLast4: String?
    private var slowTask: Task<Void, Never>?
    private let slowAfter: Duration = .seconds(8)

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

    // MARK: - Flow control

    /// Starts (or restarts) the flow from `preparing` with fresh card, vault and 3DS tokens.
    func start() {
        attempt += 1
        let attempt = attempt
        token3DS = ""
        outcome = nil
        challengeMounted = false
        setPhase(.preparing)
        isSheetPresented = true

        Task {
            do {
                let token = try await createTokens()
                guard attempt == self.attempt else { return }
                guard let token, !token.isEmpty else {
                    setPhase(.failed(detail: "Error creating standalone 3DS token!"))
                    return
                }
                token3DS = token
                setPhase(.verifying)
            } catch {
                guard attempt == self.attempt else { return }
                setPhase(.failed(detail: "Error creating the card, vault or 3DS token!"))
            }
        }
    }

    /// "Done" / "Close" — dismisses the sheet; teardown happens in ``sheetDidDismiss()``.
    func close() {
        isSheetPresented = false
    }

    /// Sheet dismissed (button or swipe): tears the widget down and drops late callbacks.
    func sheetDidDismiss() {
        attempt += 1
        slowTask?.cancel()
        token3DS = ""
        challengeMounted = false
        isSlow = false
        phase = .preparing
    }

    // MARK: - Tokenisation

    private func createTokens() async throws -> String? {
        let req = DataPaymentSources.CreatePaymentSourceTokenReq(
            cardNumber: "4100000000005000",
            cardName: "Test Card",
            expireMonth: "09",
            expireYear: "39",
            cardCcv: "100",
            storeCcv: true)
        cardLast4 = req.cardNumber.map { String($0.suffix(4)) }
        let cardToken = try await paymentSourcesService.createToken(tokeniseCardDetailsReq: req, widgetAccessToken: apiAccessToken)
        let vaultTokenReq = DataVault.ConvertToVaultTokenReq(token: cardToken, vaultType: "session")
        let vaultToken = try await vaultService.createVaultToken(request: vaultTokenReq, apiAccessToken: apiAccessToken)
        return try await standalone3dsService.createStandalone3DSToken(request: make3dsRequest(vaultToken: vaultToken),
                                                                       apiAccessToken: apiAccessToken)
    }

    private func make3dsRequest(vaultToken: String) -> DataStandalone3ds.Standalone3DSReq {
        DataStandalone3ds.Standalone3DSReq(
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
    }

    // MARK: - Handle Callbacks
    // Callbacks are hopped onto a new main-actor task: the widget may report synchronously while SwiftUI is
    // building the view (e.g. an invalid token), and published state must not change mid-update.

    /// Final outcomes only — intermediate results (`chargeAuthChallenge` / `chargeAuthDecoupled` /
    /// `chargeAuthInfo`) never end the flow; the phases are driven by ``handleProgress(_:)``.
    func handle3dsEvent(_ result: Standalone3DSResult) {
        Task {
            guard isWidgetActive else { return }
            switch result.event {
            case .chargeAuthSuccess:
                outcome = Standalone3DSDemoOutcome(
                    status: result.status,
                    resultDescription: result.resultDescription,
                    charge3dsId: result.charge3dsId,
                    flow: Standalone3DSDemoFlow(result.authenticationFlow),
                    amount: "\(configManager.getGlobalConfig().totalAmount) \(configManager.getGlobalConfig().currency)",
                    cardLast4: cardLast4)
                setPhase(.success)
            case .chargeAuthReject:
                setPhase(.declined)
            case .chargeError:
                setPhase(.failed(detail: nil))
            case .chargeAuthChallenge, .chargeAuthDecoupled, .chargeAuthInfo:
                break
            }
        }
    }

    func handleProgress(_ progress: Standalone3DSProgress) {
        Task {
            guard isWidgetActive else { return }
            switch progress {
            case .challengeStarted:
                challengeMounted = true
                setPhase(.challengeLoading)
            case .challengeLoaded:
                if phase == .challengeLoading {
                    setPhase(.challenge)
                }
            case .challengeCompleted:
                switch phase {
                case .challengeLoading, .challenge, .decoupled:
                    setPhase(.finalizing)
                default:
                    break
                }
            case let .decoupled(_, description):
                setPhase(.decoupled(description: description))
            }
        }
    }

    func handleFailure(error: Standalone3DSError) {
        Task {
            guard isWidgetActive else { return }
            setPhase(.failed(detail: error.customMessage))
        }
    }

    /// Only a mounted, still-running widget may move the phase (drops late or stale callbacks).
    private var isWidgetActive: Bool {
        isSheetPresented && !token3DS.isEmpty && phase != .preparing && !phase.isTerminal
    }

    private func setPhase(_ newPhase: Standalone3DSDemoPhase) {
        phase = newPhase
        slowTask?.cancel()
        isSlow = false
        if newPhase == .verifying {
            slowTask = Task { [weak self, slowAfter] in
                try? await Task.sleep(for: slowAfter)
                guard !Task.isCancelled else { return }
                self?.isSlow = true
            }
        }
        if newPhase.isTerminal {
            // Tokens are single-use: tear the widget down once the authentication has ended.
            token3DS = ""
        }
    }
}
