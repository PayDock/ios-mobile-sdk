# DataMPGS3ds

A Swift Package for handling Mastercard Payment Gateway Services (MPGS) Integrated 3D Secure (3DS) authentication in the Paydock iOS SDK.

## Overview

`DataMPGS3ds` provides request/response models, endpoints, and services for MPGS Integrated 3DS authentication flows. This package enables you to initiate 3DS authentication for card payments and handle the authentication response.

## Contents

### Requests
- **`MPGS3dsReq`**: Request model for POST `/v1/charges/3ds` - initiating Integrated 3DS authentication with a payment token
- **`MPGS3dsVaultReq`**: Request model for POST `/v1/charges/3ds` - initiating Integrated 3DS authentication with a vault token

### Responses
- **`MPGS3dsRes`**: Response model for Integrated 3DS authentication operations

### Services
- **`MPGS3dsService`**: Protocol and implementation for MPGS 3DS API calls
- **`MPGS3dsServiceImpl`**: Default implementation of `MPGS3dsService`

### Endpoints
- **`MPGS3dsEndpoints`**: Enum defining MPGS 3DS API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ErrorSummary`)

## Usage

### Importing

```swift
import DataMPGS3ds
```

### Initializing the Service

```swift
let mpgs3dsService: MPGS3dsService = MPGS3dsServiceImpl()
```

### Initiating 3DS Authentication with Payment Token

```swift
let request = MPGS3dsReq(
    amount: "100.00",
    currency: "AUD",
    threeDS: MPGS3dsData(
        browserDetails: MPGS3dsBrowserDetails(
            acceptHeader: "text/html",
            javaEnabled: true,
            language: "en-AU",
            colorDepth: "24",
            screenHeight: 1920,
            screenWidth: 1080,
            timezone: 660,
            userAgent: "Mozilla/5.0..."
        )
    ),
    token: "payment-token-123" // OTT token from PaymentSourcesService
)

do {
    let response = try await mpgs3dsService.createMPGS3dsToken(
        request: request,
        apiAccessToken: "your-api-token"
    )
    
    if let token3DS = response {
        // Use the 3DS token to display the authentication web view
        print("3DS Token: \(token3DS)")
    }
} catch {
    print("Error: \(error)")
}
```

### Initiating 3DS Authentication with Vault Token

```swift
let vaultRequest = MPGS3dsVaultReq(
    amount: "100.00",
    currency: "AUD",
    threeDS: MPGS3dsData(
        browserDetails: MPGS3dsBrowserDetails(
            acceptHeader: "text/html",
            javaEnabled: true,
            language: "en-AU",
            colorDepth: "24",
            screenHeight: 1920,
            screenWidth: 1080,
            timezone: 660,
            userAgent: "Mozilla/5.0..."
        )
    ),
    vaultToken: "vault-token-456"
)

do {
    let response = try await mpgs3dsService.createMPGS3dsVaultToken(
        request: vaultRequest,
        apiAccessToken: "your-api-token"
    )
    
    // Access the 3DS token from the response
    if let token3DS = response.resource.data.threeDS.token {
        print("3DS Token: \(token3DS)")
    }
} catch {
    print("Error: \(error)")
}
```

## Complete Flow Example

```swift
// 1. First, create a payment source token (using DataPaymentSources)
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

let cardToken = try await paymentSourcesService.createCardToken(
    tokeniseCardDetailsReq: cardTokenReq,
    apiAccessToken: apiToken
)

// 2. Then, initiate 3DS authentication
let mpgs3dsService: MPGS3dsService = MPGS3dsServiceImpl()
let threeDSReq = MPGS3dsReq(
    amount: "100.00",
    currency: "AUD",
    threeDS: MPGS3dsData(browserDetails: MPGS3dsBrowserDetails()),
    token: cardToken
)

let threeDSToken = try await mpgs3dsService.createMPGS3dsToken(
    request: threeDSReq,
    apiAccessToken: apiToken
)

// 3. Use the 3DS token to display authentication web view
// (Implementation depends on your UI framework)
```

## API Endpoints

- `POST /v1/charges/3ds` - Initiate Integrated 3DS authentication

## Response Structure

The `MPGS3dsRes` includes:
- `status`: HTTP status code
- `error`: Error information (if any)
- `resource`: Charge resource containing:
  - `type`: Resource type ("charge")
  - `data`: Charge data including:
    - `id`: Charge ID
    - `threeDS`: 3DS authentication data containing:
      - `token`: Base64-encoded 3DS authentication token (used for web view)
      - `id`: 3DS authentication ID

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


