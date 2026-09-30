//
//  Standalone3DSExampleView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI
import UIKit
import MobileSDK

struct Standalone3DSExampleView: View {

    @StateObject private var viewModel = Standalone3DSExampleVM()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Text("Runs a standalone 3-D Secure authentication for a test card.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("Start verification", action: viewModel.start)
                    .accessibilityIdentifier("Start 3DS")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.defaultPrimary)
                    .cornerRadius(8)
                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#EAE0D7"))
        }
        .sheet(isPresented: $viewModel.isSheetPresented, onDismiss: viewModel.sheetDidDismiss) {
            Standalone3DSDemoSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.start()
        }
    }
}

// MARK: - Sheet

private struct Standalone3DSDemoSheet: View {
    @ObservedObject var viewModel: Standalone3DSExampleVM
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let compactDetent: PresentationDetent = .height(360)

    var body: some View {
        NavigationStack {
            ZStack {
                // The widget stays mounted at full size (its JS and the ACS iframe must keep running) and is only
                // made visible and interactive for the challenge. Never hide it, collapse it or remove it earlier.
                if !viewModel.token3DS.isEmpty {
                    Standalone3DSWidget(
                        config: ThreeDSConfig(token: viewModel.token3DS),
                        appearance: viewModel.getAppearance(isDarkMode: colorScheme == .dark),
                        loadingDelegate: viewModel.loadingDelegate,
                        onProgress: { progress in
                            viewModel.handleProgress(progress)
                        },
                        completion: { result in
                            switch result {
                            case .success(let result):
                                viewModel.handle3dsEvent(result)
                            case .failure(let error):
                                viewModel.handleFailure(error: error)
                            }
                        })
                    .id(viewModel.token3DS)
                    .opacity(isChallengeVisible ? 1 : 0)
                    .allowsHitTesting(isChallengeVisible)
                    .accessibilityHidden(!isChallengeVisible)
                }

                if !isChallengeVisible {
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                        .transition(.opacity)
                }
            }
            .navigationTitle("Secure verification · 3-D Secure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.close) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close 3-D Secure verification")
                }
            }
        }
        .presentationDetents([detent])
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.phase)
    }

    private var isChallengeVisible: Bool {
        viewModel.phase == .challenge
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.phase == .success, let outcome = viewModel.outcome {
            Standalone3DSSuccessView(outcome: outcome, onRunAgain: viewModel.start, onDone: viewModel.close)
        } else {
            Standalone3DSStatusOverlay(phase: viewModel.phase,
                                       isSlow: viewModel.isSlow,
                                       onRetry: viewModel.start,
                                       onClose: viewModel.close)
        }
    }

    /// Compact until a challenge is announced; expanded for the challenge and for the success details.
    private var detent: PresentationDetent {
        switch viewModel.phase {
        case .challengeLoading, .challenge, .success:
            return .large
        case .finalizing:
            return viewModel.challengeMounted ? .large : Self.compactDetent
        default:
            return Self.compactDetent
        }
    }
}

// MARK: - Status overlay

private struct Standalone3DSStatusOverlay: View {
    let phase: Standalone3DSDemoPhase
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
            if case let .failed(detail?) = phase {
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            if phase.isTerminal {
                Standalone3DSActionButtons(primaryTitle: "Try again",
                                           secondaryTitle: "Close",
                                           onPrimary: onRetry,
                                           onSecondary: onClose)
                    .padding(.top, 8)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var icon: some View {
        if phase.isTerminal {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.red)
                .accessibilityHidden(true)
        } else {
            ProgressView()
                .controlSize(.large)
        }
    }

    private var title: String {
        switch phase {
        case .preparing: return "Preparing secure verification"
        case .verifying: return isSlow ? "Still working — contacting your bank" : "Verifying your payment"
        case .challengeLoading: return "Your bank is asking for verification"
        case .challenge: return ""
        case .finalizing: return "Completing verification"
        case .decoupled: return "Approve the payment in your banking app"
        case .success: return "Payment verified"
        case .declined: return "Verification declined"
        case .failed: return "Something went wrong"
        }
    }

    private var subtitle: String {
        switch phase {
        case .preparing: return "Setting up 3-D Secure with your bank…"
        case .verifying: return "This usually only takes a few seconds."
        case .challengeLoading: return "Loading the verification step…"
        case .challenge: return ""
        case .finalizing: return "Confirming the result with your bank…"
        case let .decoupled(description):
            if let description, !description.isEmpty { return description }
            return "Once you approve it there, this page will update automatically."
        case .success: return "Authentication completed successfully."
        case .declined: return "Your bank declined the authentication for this payment."
        case .failed: return "An unexpected error interrupted the authentication."
        }
    }
}

private struct Standalone3DSActionButtons: View {
    let primaryTitle: String
    let secondaryTitle: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(primaryTitle, action: onPrimary)
                .accessibilityIdentifier("\(primaryTitle) 3DS")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.defaultPrimary)
                .cornerRadius(8)
            Button(secondaryTitle, action: onSecondary)
                .accessibilityIdentifier("\(secondaryTitle) 3DS")
                .font(.system(size: 16, weight: .semibold))
                .frame(height: 44)
        }
    }
}

// MARK: - Success

private struct Standalone3DSSuccessView: View {
    let outcome: Standalone3DSDemoOutcome
    let onRunAgain: () -> Void
    let onDone: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ringProgress: CGFloat = 0
    @State private var checkProgress: CGFloat = 0
    @State private var badgeScale: CGFloat = 1
    @State private var showsDetails = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                badge
                    .padding(.top, 24)
                Text("Payment verified")
                    .font(.system(size: 18, weight: .semibold))
                Text("Authentication completed successfully.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Group {
                    Standalone3DSDetailsCard(outcome: outcome)
                    Standalone3DSActionButtons(primaryTitle: "Run again",
                                               secondaryTitle: "Done",
                                               onPrimary: onRunAgain,
                                               onSecondary: onDone)
                }
                .opacity(showsDetails ? 1 : 0)
                .offset(y: showsDetails ? 0 : 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .task { await animate() }
    }

    private var badge: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Standalone3DSCheckmark()
                .trim(from: 0, to: checkProgress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .padding(18)
        }
        .frame(width: 76, height: 76)
        .scaleEffect(badgeScale)
        .accessibilityHidden(true)
    }

    /// Ring → checkmark → pop (1 → 1.12 → 1) → details. With Reduce Motion the final state is shown at once.
    private func animate() async {
        guard !reduceMotion else {
            ringProgress = 1
            checkProgress = 1
            showsDetails = true
            return
        }
        withAnimation(.easeOut(duration: 0.4)) { ringProgress = 1 }
        guard await pause(0.35) else { return }
        withAnimation(.easeOut(duration: 0.25)) { checkProgress = 1 }
        guard await pause(0.25) else { return }
        withAnimation(.easeOut(duration: 0.12)) { badgeScale = 1.12 }
        guard await pause(0.12) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { badgeScale = 1 }
        guard await pause(0.1) else { return }
        withAnimation(.easeOut(duration: 0.35)) { showsDetails = true }
    }

    /// Sleeps for `seconds`; `false` when the view went away meanwhile.
    private func pause(_ seconds: Double) async -> Bool {
        try? await Task.sleep(for: .seconds(seconds))
        return !Task.isCancelled
    }
}

private struct Standalone3DSCheckmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.minY + rect.height * 0.78))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.9, y: rect.minY + rect.height * 0.24))
        return path
    }
}

private struct Standalone3DSDetailsCard: View {
    let outcome: Standalone3DSDemoOutcome

    var body: some View {
        VStack(spacing: 0) {
            row("Status", outcome.status ?? "—")
            if let resultDescription = outcome.resultDescription {
                row("Description", resultDescription)
            }
            row("Charge 3DS ID", outcome.charge3dsId.isEmpty ? "—" : outcome.charge3dsId,
                monospaced: true, copyable: !outcome.charge3dsId.isEmpty)
            row("Flow", outcome.flow.rawValue)
            row("Amount", outcome.amount)
            if let cardLast4 = outcome.cardLast4 {
                row("Card", "•••• \(cardLast4)", monospaced: true, showsDivider: false)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func row(_ label: String,
                     _ value: String,
                     monospaced: Bool = false,
                     copyable: Bool = false,
                     showsDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer(minLength: 8)
                    Text(value)
                        .font(monospaced ? .system(size: 13, design: .monospaced) : .system(size: 14, weight: .medium))
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .accessibilityElement(children: .combine)
                if copyable {
                    Button {
                        UIPasteboard.general.string = value
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                    }
                    .accessibilityLabel("Copy \(label)")
                }
            }
            .padding(.vertical, 12)
            if showsDivider {
                Divider()
            }
        }
    }
}

struct Standalone3DSWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Standalone3DSExampleView()
    }
}
