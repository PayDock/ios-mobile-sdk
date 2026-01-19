# DataVault

A Swift Package for handling payment source vault operations in the Paydock iOS SDK.

## Overview

`DataVault` provides request/response models, endpoints, and services for converting One-Time Tokens (OTT) to vault tokens. Vault tokens allow you to securely store payment methods for future use without handling sensitive card details.

## Contents

### Requests
- **`ConvertToVaultTokenReq`**: Request model for POST `/v1/vault/payment_sources` - converting an OTT token to a vault token

### Responses
- **`VaultTokenRes`**: Response model for vault token conversion operations

### Services
- **`VaultService`**: Protocol and implementation for vault API calls
- **`VaultServiceImpl`**: Default implementation of `VaultService`

### Endpoints
- **`VaultEndpoints`**: Enum defining vault API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ErrorSummary`)

## Usage

### Importing

```swift
import DataVault
```

### Initializing the Service

```swift
let vaultService: VaultService = VaultServiceImpl()
```

### Converting OTT Token to Vault Token

```swift
import DataPaymentSources

// First, create an OTT token (using DataPaymentSources)
let paymentSourcesService: PaymentSourcesService = PaymentSourcesServiceImpl()
let cardTokenReq = CreatePaymentSourceTokenReq(
    gatewayId: "gateway-123",
    cardNumber: "5123450000000008",
    cardName: "John Doe",
    expireMonth: "12",
    expireYear: "25",
    cardCcv: "123",
    storeCcv: true
)

let ottToken = try await paymentSourcesService.createCardToken(
    tokeniseCardDetailsReq: cardTokenReq,
    apiAccessToken: apiToken
)

// Then, convert to vault token
let vaultRequest = ConvertToVaultTokenReq(
    token: ottToken,
    vaultType: "session" // or "permanent" for long-term storage
)

do {
    let vaultToken = try await vaultService.createVaultToken(
        request: vaultRequest,
        apiAccessToken: "your-api-token"
    )
    print("Vault Token: \(vaultToken)")
    // Store this vault token securely for future use
} catch {
    print("Error: \(error)")
}
```

### Using Vault Token for Charges

Once you have a vault token, you can use it for future charges:

```swift
import DataCharges

let chargeRequest = CaptureChargeReq(
    amount: "100.00",
    currency: "AUD",
    customer: ChargeCustomer(
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        paymentSource: ChargePaymentSource(
            vaultToken: vaultToken // Use the stored vault token
        )
    ),
    reference: "order-123"
)

let chargesService: ChargesService = ChargesServiceImpl()
let chargeResponse = try await chargesService.captureCharge(
    request: chargeRequest,
    apiAccessToken: apiToken
)
```

### Using Vault Token for 3DS Authentication

Vault tokens can also be used for 3DS authentication:

```swift
import DataMPGS3ds

let threeDSRequest = MPGS3dsVaultReq(
    amount: "100.00",
    currency: "AUD",
    threeDS: MPGS3dsData(browserDetails: MPGS3dsBrowserDetails()),
    vaultToken: vaultToken // Use the stored vault token
)

let mpgs3dsService: MPGS3dsService = MPGS3dsServiceImpl()
let response = try await mpgs3dsService.createMPGS3dsVaultToken(
    request: threeDSRequest,
    apiAccessToken: apiToken
)
```

## Vault Types

- **`session`**: Temporary vault token that expires at the end of the session
- **`permanent`**: Long-term vault token that persists until explicitly deleted

## API Endpoints

- `POST /v1/vault/payment_sources` - Convert OTT token to vault token

## Response Structure

The `VaultTokenRes` includes:
- `status`: HTTP status code (typically 201)
- `error`: Error information (if any)
- `errorSummary`: Detailed error summary (if any)
- `resource`: Payment source resource containing:
  - `type`: Resource type ("payment_source")
  - `data`: Payment source data including:
    - `vaultToken`: The vault token (UUID format)
    - `type`: Payment source type (e.g., "card", "card_scheme_token")
    - `cardNumberLast4`: Last 4 digits of the card
    - `cardScheme`: Card scheme (e.g., "visa", "mastercard")
    - `expireMonth`, `expireYear`: Card expiration details
    - `vaultType`: Type of vault ("session" or "permanent")
    - `status`: Payment source status ("active")

## Security Best Practices

- **Store vault tokens securely** using Keychain or secure storage
- **Use session tokens** for temporary storage during checkout flows
- **Use permanent tokens** only when necessary and with user consent
- **Never log or expose vault tokens** in plain text
- **Implement token rotation** for enhanced security

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


