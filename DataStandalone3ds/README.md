# DataStandalone3ds

A Swift Package for handling Standalone 3D Secure (3DS) authentication in the Paydock iOS SDK.

## Overview

`DataStandalone3ds` provides request/response models, endpoints, and services for Standalone 3DS authentication flows. This package enables you to initiate 3DS authentication independently and then capture the charge after authentication is complete.

## Contents

### Requests
- **`Standalone3DSReq`**: Request model for POST `/v1/charges/standalone-3ds` - initiating Standalone 3DS authentication

### Responses
- **`Standalone3dsRes`**: Response model for Standalone 3DS authentication operations

### Services
- **`Standalone3dsService`**: Protocol and implementation for Standalone 3DS API calls
- **`Standalone3dsServiceImpl`**: Default implementation of `Standalone3dsService`

### Endpoints
- **`Standalone3dsEndpoints`**: Enum defining Standalone 3DS API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ErrorSummary`)

## Usage

### Importing

```swift
import DataStandalone3ds
```

### Initializing the Service

```swift
let standalone3dsService: Standalone3dsService = Standalone3dsServiceImpl()
```

### Initiating Standalone 3DS Authentication

```swift
let request = Standalone3DSReq(
    amount: "100.00",
    currency: "AUD",
    reference: "order-123",
    customer: Standalone3DSCustomer(
        paymentSource: Standalone3DSPaymentSource(
            vaultToken: "vault-token-123"
        )
    ),
    threeDS: Standalone3DSData(
        authentication: Standalone3DSAuthentication(
            type: "01",
            version: "2.2.0",
            date: "2025-06-01T13:00:00.521Z",
            customer: Standalone3DSCustomerData(
                createdAt: "2025-05-31T13:06:05.521Z",
                updatedAt: "2025-05-31T13:06:05.521Z",
                credentialsUpdatedAt: "2025-05-31T13:06:05.521Z",
                suspicious: false,
                paymentSource: Standalone3DSCustomerPaymentSource(
                    createdAt: "2025-05-31T13:06:05.521Z",
                    addAttempts: ["2025-05-31T13:06:05.521Z"],
                    cardType: "02"
                )
            )
        ),
        serviceId: "service-123"
    )
)

do {
    let response = try await standalone3dsService.createStandalone3DSToken(
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

## Complete Flow Example

```swift
import DataPaymentSources
import DataVault
import DataStandalone3ds
import DataCharges

// 1. Create payment source token
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

// 2. Convert to vault token
let vaultService: VaultService = VaultServiceImpl()
let vaultReq = ConvertToVaultTokenReq(
    token: cardToken,
    vaultType: "session"
)

let vaultToken = try await vaultService.createVaultToken(
    request: vaultReq,
    apiAccessToken: apiToken
)

// 3. Initiate Standalone 3DS authentication
let standalone3dsService: Standalone3dsService = Standalone3dsServiceImpl()
let threeDSReq = Standalone3DSReq(
    amount: "100.00",
    currency: "AUD",
    reference: UUID().uuidString,
    customer: Standalone3DSCustomer(
        paymentSource: Standalone3DSPaymentSource(
            vaultToken: vaultToken
        )
    ),
    threeDS: Standalone3DSData(
        authentication: Standalone3DSAuthentication(
            type: "01",
            version: "2.2.0",
            date: ISO8601DateFormatter().string(from: Date()),
            customer: Standalone3DSCustomerData(
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                credentialsUpdatedAt: ISO8601DateFormatter().string(from: Date()),
                suspicious: false,
                paymentSource: Standalone3DSCustomerPaymentSource(
                    createdAt: ISO8601DateFormatter().string(from: Date()),
                    addAttempts: [ISO8601DateFormatter().string(from: Date())],
                    cardType: "02"
                )
            )
        ),
        serviceId: "service-123"
    )
)

let threeDSToken = try await standalone3dsService.createStandalone3DSToken(
    request: threeDSReq,
    apiAccessToken: apiToken
)

// 4. Display 3DS authentication web view using the token
// (Implementation depends on your UI framework)

// 5. After authentication completes, capture the charge
let chargesService: ChargesService = ChargesServiceImpl()
let captureReq = CaptureChargeStandaloneReq(
    amount: "100.00",
    currency: "AUD",
    customer: ChargeCustomer(
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        paymentSource: ChargePaymentSource(
            vaultToken: vaultToken
        )
    ),
    description: "Purchase order",
    reference: "order-123",
    threeDSChargeId: chargeId // From the 3DS response
)

let chargeResponse = try await chargesService.captureChargeForStandaloneFlow(
    request: captureReq,
    apiAccessToken: apiToken
)
```

## API Endpoints

- `POST /v1/charges/standalone-3ds` - Initiate Standalone 3DS authentication

## Response Structure

The `Standalone3dsRes` includes:
- `status`: HTTP status code (typically 201)
- `error`: Error information (if any)
- `errorSummary`: Detailed error summary (if any)
- `resource`: Charge resource containing:
  - `type`: Resource type ("charge")
  - `data`: Charge data including:
    - `id`: Charge ID
    - `status`: Charge status (typically "pre_authentication_pending")
    - `threeDS`: 3DS authentication data containing:
      - `token`: Base64-encoded 3DS authentication token (used for web view)
      - `id`: 3DS authentication ID
      - `authentication`: Authentication details

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


