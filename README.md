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
3.  **Structure:** The `*.xcconfig` file should contain key-value pairs for each configuration setting.
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
