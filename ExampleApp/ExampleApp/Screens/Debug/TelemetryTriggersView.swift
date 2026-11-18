//
//  TelemetryTriggersView.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import SwiftUI
import MobileSDK

/// Debug builds only: one row per telemetry trigger with what it records and its note, the SDK test crash's launch
/// variable, the uncovered uncaught errors and the empty config IDs. Records reach devdock only while telemetry is
/// active (see the README's "Telemetry (debug builds)").
struct TelemetryTriggersView: View {

    @StateObject private var viewModel = TelemetryTriggersVM()

    var body: some View {
        List {
            Section {
                ForEach(TelemetryTrigger.allCases, id: \.self) { trigger in
                    row(trigger)
                }
            } header: {
                Text("Triggers")
            }

            if let lastResult = viewModel.lastResult {
                Section {
                    Text(lastResult)
                        .font(.caption)
                } header: {
                    Text("Last result")
                }
            }

            Section {
                Text("SDK crash: set PAYDOCK_TELEMETRY_TEST_CRASH to true in an unshared copy of the scheme and launch.")
                    .font(.caption)
                Text("Uncaught errors: no trigger, covered by the SDK's tests.")
                    .font(.caption)
            } header: {
                Text("Not triggered here")
            }

            Section {
                if viewModel.emptyConfigIds.isEmpty {
                    Text("None")
                        .font(.caption)
                } else {
                    ForEach(viewModel.emptyConfigIds, id: \.self) { name in
                        Text(name)
                            .font(.caption)
                    }
                }
            } header: {
                Text("Empty config IDs")
            }
        }
        .navigationTitle("Telemetry triggers")
        .sheet(item: $viewModel.sheet) { sheet in
            switch sheet {
            case .standalone3ds:
                Standalone3DSWidget(config: ThreeDSConfig(token: "")) { _ in }
            case .applePaySetup:
                ApplePaySetupWidget()
                    .frame(height: 50)
                    .padding()
            }
        }
    }

    private func row(_ trigger: TelemetryTrigger) -> some View {
        Button {
            viewModel.run(trigger)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trigger.title)
                        .font(.headline)
                    Spacer()
                    if viewModel.running == trigger {
                        ProgressView()
                    }
                }
                Text(trigger.records)
                    .font(.caption)
                if let note = trigger.note {
                    Text(note)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(viewModel.running != nil)
        .accessibilityIdentifier("telemetryTrigger_\(trigger)")
    }
}
#endif
