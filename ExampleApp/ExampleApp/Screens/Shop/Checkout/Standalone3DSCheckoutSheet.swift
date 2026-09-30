//
//  Standalone3DSCheckoutSheet.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import SwiftUI
import MobileSDK

/// Presentation phases of the checkout's standalone 3DS sheet.
enum Standalone3DSPhase: Equatable {
    /// The 3DS token is being created.
    case preparing
    /// The widget is running (fingerprint / processing).
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
    /// `declined` is `true` when the bank declined the authentication, `false` when an error interrupted it.
    case failed(message: String, declined: Bool = false)

    var isTerminal: Bool {
        switch self {
        case .success, .failed: return true
        default: return false
        }
    }
}

/// Supplied as the widget's `loadingDelegate` only so the SDK doesn't show its own overlay —
/// the sheet's phase overlay (driven by `onProgress` / `completion`) is the single loader.
final class SilentWidgetLoadingDelegate: WidgetLoadingDelegate {
    func loadingDidStart() {}
    func loadingDidFinish() {}
}

struct Standalone3DSCheckoutSheet: View {
    @ObservedObject var viewModel: EnhancedCheckoutVM

    private static let compactDetent: PresentationDetent = .height(340)

    var body: some View {
        NavigationStack {
            ZStack {
                // The widget stays in the hierarchy (its JS must keep running) but is only visible during the challenge.
                if !viewModel.token3DS.isEmpty {
                    Standalone3DSWidget(
                        config: .init(token: viewModel.token3DS),
                        loadingDelegate: viewModel.standalone3dsLoadingDelegate,
                        onProgress: { progress in
                            viewModel.handleStandalone3dsProgress(progress)
                        },
                        completion: { result in
                            switch result {
                            case let .success(result):
                                viewModel.handleStandalone3dsEvent(result)
                            case let .failure(error):
                                viewModel.handleStandalone3dsFailure(error)
                            }
                        })
                    .id(viewModel.token3DS)
                    .opacity(viewModel.standalone3dsPhase == .challenge ? 1 : 0)
                    .accessibilityHidden(viewModel.standalone3dsPhase != .challenge)
                }

                if viewModel.standalone3dsPhase != .challenge {
                    Standalone3DSPhaseOverlay(
                        phase: viewModel.standalone3dsPhase,
                        isSlow: viewModel.standalone3dsIsSlow,
                        onRetry: viewModel.retryStandalone3ds,
                        onClose: viewModel.closeStandalone3ds)
                }
            }
            .navigationTitle("3DS Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.closeStandalone3ds()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel 3-D Secure verification")
                }
            }
        }
        .presentationDetents([detent])
        .animation(.easeInOut(duration: 0.25), value: viewModel.standalone3dsPhase)
    }

    /// Compact while loading / showing a result; expanded to the challenge height once a challenge is announced.
    private var detent: PresentationDetent {
        switch viewModel.standalone3dsPhase {
        case .challengeLoading, .challenge:
            return .large
        case .finalizing:
            return viewModel.standalone3dsChallengeMounted ? .large : Self.compactDetent
        default:
            return Self.compactDetent
        }
    }
}

private struct Standalone3DSPhaseOverlay: View {
    let phase: Standalone3DSPhase
    let isSlow: Bool
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            icon
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if case .failed = phase {
                VStack(spacing: 8) {
                    Button("Try again", action: onRetry)
                        .accessibilityIdentifier("Try again 3DS")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.defaultPrimary)
                        .cornerRadius(8)
                    Button("Close", action: onClose)
                        .accessibilityIdentifier("Close 3DS")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 44)
                }
                .padding(.top, 8)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var icon: some View {
        switch phase {
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.red)
        default:
            ProgressView()
                .controlSize(.large)
        }
    }

    private var title: String {
        switch phase {
        case .preparing: return "Preparing secure verification"
        case .verifying: return "Verifying your payment"
        case .challengeLoading: return "Your bank is asking for verification"
        case .challenge: return ""
        case .finalizing: return "Completing verification"
        case .decoupled: return "Approve the payment in your banking app"
        case .success: return "Payment verified"
        case let .failed(_, declined): return declined ? "Verification declined" : "Something went wrong"
        }
    }

    private var subtitle: String {
        switch phase {
        case .preparing: return "Setting up 3-D Secure with your bank…"
        case .verifying: return isSlow ? "Still working — contacting your bank" : "This usually only takes a few seconds."
        case .challengeLoading: return "Loading the verification step…"
        case .challenge: return ""
        case .finalizing: return "Confirming the result with your bank…"
        case let .decoupled(description):
            if let description, !description.isEmpty { return description }
            return "Once you approve it there, this page will update automatically."
        case .success: return "Authentication completed successfully."
        case let .failed(message, _): return message
        }
    }
}
