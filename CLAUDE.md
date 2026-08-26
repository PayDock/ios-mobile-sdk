# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Part of the **SDKDev** workspace — see the [workspace overview](../CLAUDE.md) for how this repo relates to the other Paydock SDK repos (client-sdk, mobile-sdk-android, the networking libs, checkout-service).

## What this is

The Paydock **iOS MobileSDK** — a Swift Package Manager package (product `MobileSDK`, library) that gives host apps pre-built SwiftUI payment widgets: card tokenisation, Apple Pay, PayPal (+ PayPal Vault), Afterpay, Coles Pay, Zip, Click to Pay, gift cards, address capture, and 3DS challenges (MPGS and standalone/GPayments). Distributed as a Swift package (`github.com/PayDock/ios-mobile-sdk`); latest released version is **4.5.0** (`CHANGELOG.md`), with unreleased work on this branch (`[Unreleased]`) adding stable machine-readable error codes and bumping `ios-core-networking` to `1.3.0`. Minimum deployment target is **iOS 16.2+** (the manifest declares `.iOS(.v16)` / `.macOS(.v12)`).

## Toolchain & setup

- **swift-tools-version 5.7.1** (`Package.swift`); build with a current stable Xcode / Swift 5.7.1+ toolchain.
- Run `make setup` once after cloning — it invokes `scripts/ensure-validation.sh`, which installs the git `pre-commit` / `pre-push` hooks that enforce branch naming (see Conventions). `make status` shows hook state; `make clean-hooks` removes them.
- `Gemfile` + `fastlane/` back CI release automation (GitLab CI, `.gitlab-ci.yml`); not needed for local dev.

## Common commands

```bash
swift build                                   # build all SPM targets
swift test                                    # run all module + SDK tests
swift test --filter DataChargesTests          # single module test bundle
swift test --filter MobileSDKTests            # core SDK tests
make validate-branch                          # check the current branch name
```

- **SwiftLint** runs automatically as an SPM build-tool plugin (`SwiftLintBuildToolPlugin` from the `SwiftLintPlugins` package) on the `MobileSDK` and `MobileSDKTests` targets, so `swift build`/`swift test` lint as they compile. Config is `.swiftlint.yml`.
- Test-bundle filter names match the target names in `Package.swift`: `CommonModelsTests`, `DataGatewaysTests`, `DataPaymentSourcesTests`, `DataChargesTests`, `DataCustomerTests`, `DataVaultTests`, `DataMPGS3dsTests`, `DataStandalone3dsTests`, `BinProcessingTests`, `MobileSDKTests`.

### Running the ExampleApp (sample app)

1. Fill the environment config in `ExampleApp/ExampleApp/Configs/` — `Staging.xcconfig`, `Sandbox.xcconfig`, `Production.xcconfig`. Only the environment(s) you actually run need values; missing keys cause build-time errors. Keys include `ACCESS_TOKEN_API`, `ACCESS_TOKEN_WIDGET`, and per-gateway service IDs (`SERVICE_ID_APPLE_PAY`, `SERVICE_ID_PAYPAL`, `SERVICE_ID_AFTERPAY`, `SERVICE_ID_COLES_PAY` + `WALLET_ID_COLES_PAY`, `SERVICE_ID_CLICK_TO_PAY`, `SERVICE_ID_ZIP`, `SERVICE_ID_MPGS`/`SERVICE_ID_MPGS_TEST`, `SERVICE_ID_GPAYMENTS`, `MERCHANT_ID_APPLE_PAY`). Full list is in `README.md`.
2. Open `ExampleApp/ExampleApp.xcodeproj` in Xcode.
3. Pick a scheme. The shared schemes are **`ExampleApp Staging`**, **`ExampleApp Sandbox`**, and **`ExampleApp`** (the plain scheme builds the `Debug (Production)` / `Release (Production)` configuration — this is the "Production" variant the README refers to). Then Run.

## Architecture

The package is a **multi-target SPM layout**: one core UI target plus several per-domain "data" targets and shared support targets, all in one repo (each domain lives in a top-level directory, e.g. `DataCharges/Sources/DataCharges`).

**Core target — `MobileSDK`** (path `Sources/`): the public SwiftUI surface. `MobileSDK.swift` is a `shared` singleton; `configureMobileSDK(config:)` stores a `MobileSDKConfig`, points `NetworkingLib.shared.host` at the environment base URL (`SDKEnvironment` → `Constants.baseURL`: `api.paydock.com` / `api-sandbox.paydock.com` / `apista.paydock.com`), and kicks off BIN-data refresh. Structure:
- `Views/` — one folder per feature (`CardDetails`, `ApplePay`, `PayPal`, `PayPalVault`, `AfterPay`, `ColesPay`, `Zip`, `Mastercard` (Click to Pay), `GiftCard`, `Address`, `3DS`, `CustomComponents`). Each feature pairs a SwiftUI widget with a view model (e.g. `AfterPay/AfterpayVM.swift`).
- `Configuration/` (`MobileSDKConfig`, `Appearance/`), `Models/`, `Utils/`, `Helpers/` (fonts, formatters, validators), `Extensions/`, `Resources/` (bundled PayPal Vault JSON), `MobileSDK.docc`.

**Data\* targets** — `DataCharges`, `DataGateways`, `DataPaymentSources`, `DataVault`, `DataCustomer`, `DataMPGS3ds`, `DataStandalone3ds`. Each is a separate SPM target depending only on **`CommonModels`** and **`NetworkingLib`** (see below). Internally each follows the same shape (see `DataCharges/Sources/DataCharges`):
- `Endpoints/` — an `enum` conforming to NetworkingLib's `Endpoint` protocol (`path`, `method`, `header`, `body`, `parameters`, `mockFile`, `bundle`).
- `Requests/` + `Responses/` — Codable DTOs.
- `Services/` — a `public protocol XxxService` and a `XxxServiceImpl: HTTPClient, XxxService` (`HTTPClient` from NetworkingLib supplies `sendRequest(endpoint:responseModel:timeout:...)`), plus a `XxxMockService` used by tests.

**Feature flow** (e.g. Afterpay): a SwiftUI widget in `Sources/MobileSDK/Views/AfterPay/` holds a view model that `import`s the data module and takes a service via constructor injection defaulting to the concrete impl (`chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl()`). The VM `await`s a service method (e.g. `getAfterpayCallback(widgetAccessToken:)`), which builds a `ChargesEndpoints` case and calls `sendRequest` through `NetworkingLib`, decoding into a `Responses/` DTO. So the dependency direction is **widget (core) → Data\* service → NetworkingLib**, with `CommonModels` (`Customer`, `PaymentSource`) shared across data modules.

**Support targets:**
- **`CommonModels`** — small shared Codable types reused by multiple Data\* modules.
- **`BinProcessing`** — standalone target (no other package deps) for card-scheme detection from BIN ranges; ships an offline `Resources/JSON/card-schemes.json` and a refresh coordinator that `configureMobileSDK` starts at init (`BinDataRefreshCoordinator`, `CardSchemeDetector`).

**Third-party SDK deps** wired into the core `MobileSDK` target (all pinned `exact` in `Package.swift`): `Afterpay` (afterpay/sdk-ios `5.9.0`), and `FraudProtection` / `PaymentButtons` / `PayPalWebPayments` (paypal/paypal-ios `2.0.1`). SwiftLint tooling comes from `SimplyDanny/SwiftLintPlugins` `0.59.1`.

## Conventions & gotchas

- **NetworkingLib source (important):** `NetworkingLib` is provided by the standalone **`ios-core-networking`** package (every target depends on `.product(name: "NetworkingLib", package: "ios-core-networking")`). On this branch the dependency is a **local path override** — `Package.swift` currently declares `.package(path: "…/ios-core-networking")` with a `TODO` to revert to the remote pin `https://github.com/PayDock/ios-core-networking` `exact: "1.3.0"` once 1.3.0 is published. Because it resolves locally, `ios-core-networking` no longer appears in `Package.resolved` (which now lists only `paypal-ios` 2.0.1, `sdk-ios` 5.9.0, and `swiftlintplugins` 0.59.1); anyone building this branch must have the local `ios-core-networking` checkout available (the pinned path is developer-specific) or switch back to the commented-out remote 1.3.0 pin. The `mobile-lib-networking-android` KMP repo *also* publishes an iOS binary via its own `Package.swift`, but **that KMP iOS target is not currently used** — this repo uses only the standalone `ios-core-networking` package.
- **Branch naming is hook-enforced.** `scripts/validate-branch-name.sh` allows prefixes `bug/`, `task/`, `feature/`, `spike/`, `deploy/`; the first four **require** a Jira ticket, i.e. `bug|task|feature|spike/SDK-####-description`, while `deploy/*` (and `main`) are free-form. Note a doc mismatch: the `Makefile` help text mentions `release/*`, but the enforced script actually uses `deploy/*` — follow the script.
- **ExampleApp needs xcconfig per environment.** The app injects `ExampleApp/ExampleApp/Configs/<Env>.xcconfig` at build time; running a scheme without its config filled fails with missing-variable errors. Never commit real tokens.
- **SwiftLint** (`.swiftlint.yml`): `todo` and `inclusive_language` rules disabled; `line_length` warns at 140; identifier length 2–45 (warn); relaxed `cyclomatic_complexity` (25/30), `file_length` (600/1000), `type_body_length`, `function_parameter_count` (10/15). Runs via the build-tool plugin, so lint violations surface during normal builds.
- **Networking / SSL:** the SDK relies on the system trust store for TLS (WebView-driven flows note "default system SSL certificate validation for PCI DSS compliance"); it does not add custom certificate pinning in this layer.
- **Widget error model (recent):** every widget error type conforms to the `WidgetError` protocol (`Sources/MobileSDK/Models/Errors/WidgetError.swift`) exposing a stable, machine-readable `code`, the user-facing `customMessage`, and a technical `debugDescription`. A failed response mapping now surfaces as a `*_RESPONSE_DECODE` code (via `RequestError.decode`, whose extension in `Sources/MobileSDK/Extensions/RequestError+Extensions.swift` maps it and, when a `DecodingFailureContext` is present, names the failing key/path) instead of an indistinguishable "unknown error". This relies on `ios-core-networking` 1.3.0, where `RequestError.decode` carries a `DecodingFailureContext` associated value. Full reference: `docs/error-codes.md`.
- Sources carry the `Copyright © Paydock Ltd.` header convention.
