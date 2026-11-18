# Project Description

The Paydock iOS MobileSDK seamlessly integrates with Paydock services to easily build a payments
flow in your iOS app. The SDK provides a customisable experience with pre-built UI widgets that
handle and support various payment methods.

Once you have setup and initialised the MobileSDK in your application, you can use the MobileSDK
widgets to access payment flows. These include interacting with ApplePay, Paypal, Afterpay, ColesPay, Zip and 
Click To Pay. You can also complete 3DS challenges, capture addresses, securely collect gift card details, 
and tokenise card details.

# Requirements

- iOS 16.2 and above

# How to install and configure the SDK

1. Setup the Paydock API Integration by [contacting Paydock](https://paydock.com/contact-us/) to
   signup for a sandbox account, and then following our [integration guide](https://docs.paydock.com/#getting-started) .
2. [Setup](https://github.com/PayDock/mobile-sdk-doc/blob/main/setup/installation.md) the iOS SDK.
3. [Configure](https://github.com/PayDock/mobile-sdk-doc/blob/main/setup/installation.md#setup-the-paydock-ios-sdk) repository access.
4. [Add](https://github.com/PayDock/mobile-sdk-doc/blob/main/setup/installation.md#step-2-add-sdk-dependency) the SDK dependency to your app.
5. Use the following guide to [initialize](https://github.com/PayDock/mobile-sdk-doc/blob/main/setup/initialise.md#initialize-the-ios-sdk) your SDK.

## Client SDK version

The web-based widgets (Click to Pay, MPGS 3DS, standalone 3DS) run Paydock's Client SDK inside a `WKWebView`. This
release supports the Client SDK line `v1.150` and, by default, loads:

| Environment | Client SDK address |
|---|---|
| `.production`, `.sandbox` | the line's **stable** alias, `https://widget.paydock.com/sdk/v1.150.stable/widget.umd.min.js` |
| `.staging` | the line's **candidate** alias, `https://widget.paydock.com/sdk/v1.150.candidate/widget.umd.min.js` |

Paydock promotes patch releases of the line to the candidate alias first and to the stable alias afterwards, so they
reach your app without a Mobile SDK update. Sandbox loads the same alias as production, so what you test in sandbox is
what runs in production; staging, Paydock's internal pre-production environment, sees a release before it is promoted.

If your own controls require a fixed script, pin an exact release of the supported line. The pin applies in every
environment:

```swift
let config = try MobileSDKConfig(environment: .production,
                                 clientSdkVersion: "v1.150.1") // a plain vX.Y.Z release of the supported line
MobileSDK.shared.configureMobileSDK(config: config)
```

A pin outside the supported line, or with a suffix such as `-beta`, throws
`MobileSDKConfigError.clientSdkVersionOutsideSupportedLine`, e.g. `clientSdkVersion v1.151.0 is outside supported line
v1.150`. The initialiser without `clientSdkVersion` is unchanged and doesn't throw.

After a widget page loads, `MobileSDK.shared.loadedClientSdkVersion` returns the Client SDK version that page reported
(e.g. `v1.150.2`), and debug builds print it. It is `nil` until a page has reported one.

If the Client SDK script fails to load, or loads without providing the Client SDK, the widget ends with
`webViewFailed`.

**Release order.** A Mobile SDK release that supports a new line ships only after that line's stable alias exists: promote a
release of the line to the stable alias in the client SDK pipeline. The release pipeline's `check_client_sdk_aliases`
job (`scripts/check-client-sdk-aliases.sh`) refuses the release until the stable alias serves a script and a version
record of the line.

# Getting Started (Sample App)

This repository includes a sample application (`ExampleApp/`) that demonstrates how to integrate and use the Paydock Mobile SDK.
This example app showcases various features of the SDK and provides a practical guide for developers looking to implement Paydock payments in their own iOS applications.

## Prerequisites

Before you can run the sample app, you'll need to have the following installed:

*   **Paydock Integration** Ensure you have setup your Paydock account and signed up for your sandbox account. (As indicated in [step 1](#how-to-install-and-configure-the-sdk))
*   **Xcode:** The latest stable version of Xcode is recommended. You can download it from the [Apple's developer website](https://developer.apple.com/xcode/).
*   **Git:** You'll need Git to clone the repository.

## Configuration

The sample app uses `*.xcconfig` file to manage environment-specific settings. Each environment has a corresponding `*.xcconfig` file containing key-value pairs used during the build process. These values are injected into the app at buildtime.
The files are `Staging.xcconfig`, `Sandbox.xcconfig`, and `Production.xcconfig`

**Note:**
> You only need to fill the `*.xcconfig` file for the environments you are actively working on. For example, if you are working on `Sandbox`, you can omit the file for `Staging` and `Production`, as it is not required for your current build. In that case you only need to fill the `Sandbox.xcconfig` file.
> Ensure the necessary configuration files are in filled before running the app to avoid missing variable errors.

### `*.xcconfig` Files

1.  **Environments:** The sample app supports three environments: `Staging`, `Sandbox` and `Production`. You'll need to provide values for each environment.
2.  **Location:** Files are already created and are located in the `ExampleApp/Configs/` directory of the project.
3.  **Structure:** The `*.xcconfig` file should contain key-value pairs for each configuration setting. Keep the first line, `#include "Version.xcconfig"`: it provides the app version, and without it builds get an empty version.
4.  **Required Fields:** The following fields are used in the `config.properties` file:

*   **`ACCESS_TOKEN_API`:** The Paydock API access token for the specified environment (e.g., Sandbox, Staging, Production). This token is used by the sample app to make direct calls to the Paydock API for tasks like creating customers or managing transactions.
*   **`ACCESS_TOKEN_WIDGET`:** The Paydock Widget/UI access token for the specified environment. This token is used by the Paydock Mobile SDK to authenticate and authorize the use of the pre-built UI widgets for payment processing.
*   **`SERVICE_ID_APPLE_PAY`:** Your Paydock service ID for the Apple Pay service. This ID is required to enable Apple Pay as a payment method.
*   **`SERVICE_ID_PAYPAL`:** Your Paydock service ID for the PayPal gateway. This ID is necessary to enable PayPal as a payment method within the sample app.
*   **`SERVICE_ID_AFTERPAY`:** Your Paydock service ID for the Afterpay gateway. This ID is required to enable Afterpay as a payment method.
*   **`SERVICE_ID_COLES_PAY`:** Your Paydock service ID for the Coles Pay gateway. This ID is required to enable Coles Pay as a payment method.
*   **`WALLET_ID_COLES_PAY`:** The client ID provided by Coles Pay. This ID is required for tagging the Wallet type and using the Coles Pay service.
*   **`SERVICE_ID_CLICK_TO_PAY`:** Your Paydock service ID for using Click To Pay service. This ID is required to enable Click To Pay as a payment method.
*   **`SERVICE_ID_ZIP`:** Your Powerboard service ID for the Zip gateway. This ID is required to enable Zip as a payment method.
*   **`SERVICE_ID_MPGS`:** Your Paydock service ID for the MPGS gateway. This ID is required for 3DS check and transactions.
*   **`SERVICE_ID_MPGS_TEST`:** Your Paydock service ID for the MPGS gateway. This ID should use an MPGS merchant id starting with "TEST" for using MPGS supported test cards and 3ds challenge emulator.
*   **`SERVICE_ID_GPAYMENTS`:** Your Paydock service ID for the GPayments 3DS service. This ID is required to enable 3DS check.
*   **`MERCHANT_ID_APPLE_PAY`:** Your Apple Pay merchant ID. This ID is required to enable Apple Pay test payments in sample app.

**Example `*.xcconfig`:**
```
#include "Version.xcconfig"

// Authentication
ACCESS_TOKEN_API=your_api_access_token
ACCESS_TOKEN_WIDGET=your_widget_access_token
// MPGS
SERVICE_ID_MPGS=your_gateway_id_mpgs
SERVICE_ID_MPGS_TEST=your_gateway_id_mpgs_test
// AFTERPAY
SERVICE_ID_AFTERPAY=your_gateway_id_afterpay
// APPLE PAY
SERVICE_ID_APPLE_PAY=your_gateway_id_applepay
MERCHANT_ID_APPLE_PAY=your_merchant_id_applepay
// CLICK TO PAY
SERVICE_ID_CLICK_TO_PAY=your_gateway_id_click_to_pay
// COLES PAY
SERVICE_ID_COLES_PAY=your_gateway_id_coles_pay
WALLET_ID_COLES_PAY=your_wallet_id_coles_pay
// GPAYMENTS (Standalone 3ds)
SERVICE_ID_GPAYMENTS=your_gpayments_3ds_gateway_id
// PAYPAL
SERVICE_ID_PAYPAL=your_gateway_id_paypal
// ZIP
SERVICE_ID_ZIP=your_gateway_id_zip

```

**Note:**
> Replace the placeholder values (e.g., `your_api_access_token`) with your actual keys and IDs.

## Running the Sample App

1.  **Clone the Repository:** bash git clone https://github.com/PayDock/ios-mobile-sdk
2.  **Open in Xcode:** Open the `ExampleApp/ExampleApp.xcodeproj` file in Xcode.
3.  **Select a Build Variant:** In Xcode, select environment to run from the dropdown in the top Xcode top navigation bar and choose one of the following:
*   `ExampleApp Staging`
*   `ExampleApp Sandbox`
*   `ExampleApp Production`
4.  **Run the App:** Click the "Run" button (gray play icon) in Xcode to build and run the sample app on a simulator or a connected device.

## Telemetry (debug builds)

A debug build of the sample app on the sandbox environment can send the SDK's telemetry to devdock, and its
**Config → Telemetry triggers** screen raises each kind of record on demand. A release build holds neither the screen
nor any telemetry I/O, and a merchant app is unchanged. Details of the records: `PaydockTelemetry/README.md`.

### Scheme set-up

Duplicate the `ExampleApp Sandbox` scheme as an **unshared** copy (Product → Scheme → Manage Schemes, untick
*Shared*, so it lands in the gitignored `xcuserdata/`) and add the variables under Run → Arguments → Environment
Variables. Values come from the telemetry gateway's owner; never put them in a shared scheme, a config file or a
commit.

- `PAYDOCK_TELEMETRY_OTLP_ENDPOINT`: the telemetry gateway's OTLP endpoint (required).
- `PAYDOCK_TELEMETRY_OTLP_AUTH`: its authorization (required).
- `PAYDOCK_TELEMETRY_LEVEL`: `off`, `errors` or `all` (optional, default `all`).
- `PAYDOCK_TELEMETRY_SEND_TEST_RECORD` = `true`: store and send one test record right after start (optional).
- `PAYDOCK_TELEMETRY_TEST_CRASH` = `true`: raise a test crash from SDK code 3 s after start (optional; ends the
  process).
- `EXAMPLE_APP_TEST_CRASH` = `true`: raise a test crash from app code 3 s after launch (optional; ends the process).

Without the first two, telemetry stays inactive and the triggers record nothing.

### Triggers

**Config → Telemetry triggers** (debug builds only) runs one trigger at a time and shows only the result's type name:

| Trigger | Records |
|---|---|
| App crash | `paydock.crash`, kind `exception`, `ExampleAppTestCrash` from app code, `in_sdk` false; ends the process, the record is sent on the next launch |
| Hang | `paydock.crash`, kind `hang`, from MetricKit (see below) |
| SDK error | `paydock.error`: the standalone 3DS widget opened with an empty token |
| Widget opened | `paydock.widget.opened`: the Apple Pay set-up widget |
| HTTP 4xx | `paydock.network.failure`: GET `/v1/gateways/{id}/wallet-config` with a blank token and the fake gateway ID `telemetry-test-gateway` |
| HTTP 5xx | `paydock.network.failure`: the same call with an obviously malformed token |
| Timeout | `paydock.network.failure`, `error_type` `timeout`: the same call on a non-routable stand-in host; the call is retried once, so two records (attempts 1 and 2), after about two minutes |
| Offline | `paydock.network.failure`, a connection failure: the same call on a closed loopback port; two records (attempts 1 and 2) |

Timeout and offline point the SDK at a stand-in host for that one call only and restore the API host afterwards; a
debug build accepts the two stand-ins, a release build never does. The SDK's own test crash has no button: set
`PAYDOCK_TELEMETRY_TEST_CRASH`. Uncaught errors have no trigger; the SDK's tests cover them. The screen also lists the
names of the config IDs that are empty in the current `*.xcconfig`, never their values.

### The hang (manual)

1. Run a debug build with the scheme above **on a device**: the simulator delivers no MetricKit payloads.
2. Tap **Hang**: it blocks the main thread for 5 s.
3. Keep the app installed and open it again the next day: MetricKit delivers the hang diagnostic about a day later, and
   the SDK records it on that launch.

### Devdock queries

In Grafana Explore on the devdock Loki data source:

```
{service_name="paydock-mobile-sdk"} | app_installation_id="<id>"
{service_name="paydock-mobile-sdk"} | session_id="<id>"
{service_name="paydock-mobile-sdk"} | event_name="paydock.network.failure" | error_type="timeout"
```

Per record type, add one of: `| event_name="paydock.crash"`, `| event_name="paydock.error"`,
`| event_name="paydock.network.failure"`, `| event_name="paydock.widget.opened"`,
`| event_name="paydock.telemetry.dropped"`.

The attribute names follow Loki's OTLP mapping (dots become underscores) and are to be confirmed at the first devdock
run.
