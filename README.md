# Project Description

The Paydock iOS MobileSDK seamlessly integrates with Paydock services to easily build a payments
flow in your iOS app. The SDK provides a customisable experience with pre-built UI widgets that
handle and support various payment methods.

Once you have setup and initialised the MobileSDK in your application, you can use the MobileSDK
widgets to access payment flows. These include interacting with ApplePay, Paypal, Afterpay, Flypay and Click To Pay. You can also
complete 3DS challenges, capture addresses, securely collect gift card details, and tokenise card
details.

# Requirements

- iOS 16.2 and above

# How to install and configure the SDK

1. Setup the Paydock API Integration by [contacting Paydock](https://paydock.com/contact-us/) to
   signup for a sandbox account, and then following our [integration guide](https://docs.paydock.com/#getting-started) .
2. [Setup](https://github.com/PayDock/mobile-sdk-doc/blob/main/setup/installation.md) the iOS or Android SDK.
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

*   **`API_ACCESS_TOKEN`:** The Paydock API access token for the specified environment (e.g., Sandbox, Staging, Production). This token is used by the sample app to make direct calls to the Paydock API for tasks like creating customers or managing transactions.
*   **`WIDGET_ACCESS_TOKEN`:** The Paydock Widget/UI access token for the specified environment. This token is used by the Paydock Mobile SDK to authenticate and authorize the use of the pre-built UI widgets for payment processing.
*   **`APPLE_PAY_GATEWAY_ID`:** Your Paydock service ID for the MPGS (Mastercard Payment Gateway Services) gateway. This ID is required to process card payments, handle 3D Secure (3DS) authentication, ApplePay and manage other card-related transactions.
*   **`PAY_PAL_GATEWAY_I`:** Your Paydock service ID for the PayPal gateway. This ID is necessary to enable PayPal as a payment method within the sample app.
*   **`AFTERPAY_GATEWAY_ID`:** Your Paydock service ID for the Afterpay gateway. This ID is required to enable Afterpay as a payment method.
*   **`FLYPAY_GATEWAY_ID`:** Your Paydock service ID for the Flypay gateway. This ID is required to enable Flypay as a payment method.
*   **`FLYPAY_CLIENT_ID`:** The client ID provided by Flypay. This ID is required for authenticating and using the Flypay service.
*   **`MASTERCARD_SERVICE_ID`:** Your Paydock service ID for the ClickToPay gateway. This ID is required to enable ClickToPay as a payment method.
*   **`INTEGRATED_3DS_GATEWAY_ID`:** Your Paydock service ID for the Integrated 3DS service. This ID is required to enable 3DS check.
*   **`STANDALONE_3DS_GATEWAY_ID`:** Your Paydock service ID for the Standalone 3DS service. This ID is required to enable 3DS check.
*   **`MERCHANT_ID`:** Your ApplePay merchant ID. This ID is required to enable ApplePay test payments in sample app.

**Example `*.xcconfig`:**
```
// Authentication keys
API_ACCESS_TOKEN = your_api_access_token
WIDGET_ACCESS_TOKEN = your_widget_access_token 

// Gateway keys
APPLE_PAY_GATEWAY_ID = your_gateway_id_mpgs
PAY_PAL_GATEWAY_ID = your_gateway_id_pay_pal
INTEGRATED_3DS_GATEWAY_ID = your_integrated_3ds_gateway_id
STANDALONE_3DS_GATEWAY_ID = your_standalone_3ds_gateway_id
MASTERCARD_SERVICE_ID = your_gateway_id_click_to_pay
AFTERPAY_GATEWAY_ID = your_gateway_id_after_pay
FLYPAY_GATEWAY_ID = your_gateway_id_flypay
FLYPAY_CLIENT_ID = your_flypay_client_id
MERCHANT_ID = your_merchant_id
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
