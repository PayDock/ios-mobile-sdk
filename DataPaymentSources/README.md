# DataPaymentSources

A Swift Package for handling payment source token creation in the Paydock iOS SDK.

## Overview

`DataPaymentSources` provides request/response models, endpoints, and services for creating One-Time Tokens (OTT) from payment source details. This package enables you to tokenize card details securely before processing payments.

## Contents

### Requests
- **`CreatePaymentSourceTokenReq`**: Request model for POST `/v1/payment_sources/tokens` - creating an OTT token from card details

### Responses
- **`OTTTokenRes`**: Response model for OTT token creation operations

### Services
- **`PaymentSourcesService`**: Protocol and implementation for payment source API calls
- **`PaymentSourcesServiceImpl`**: Default implementation of `PaymentSourcesService`

### Endpoints
- **`PaymentSourcesEndpoints`**: Enum defining payment source API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ErrorSummary`)

## Usage

### Importing

```swift
import DataPaymentSources
```

### Initializing the Service

```swift
let paymentSourcesService: PaymentSourcesService = PaymentSourcesServiceImpl()
```

### Creating a Payment Source Token (OTT)

```swift
let request = CreatePaymentSourceTokenReq(
    gatewayId: "gateway-123",
    cardNumber: "5123450000000008",
    cardName: "John Doe",
    expireMonth: "12",
    expireYear: "25",
    cardCcv: "123",
    storeCcv: true // Whether to store the CVV in the vault
)

do {
    let token = try await paymentSourcesService.createCardToken(
        tokeniseCardDetailsReq: request,
        apiAccessToken: "your-api-token"
    )
    print("OTT Token: \(token)")
    // Use this token for subsequent charge operations
} catch {
    print("Error: \(error)")
}
```

### Using the Token for Charges

After creating an OTT token, you can use it in charge operations:

```swift
import DataCharges

// Create charge using the OTT token
let chargeRequest = CaptureChargeReq(
    amount: "100.00",
    currency: "AUD",
    token: ottToken, // Use the token from PaymentSourcesService
    reference: "order-123"
)

let chargesService: ChargesService = ChargesServiceImpl()
let chargeResponse = try await chargesService.captureCharge(
    request: chargeRequest,
    apiAccessToken: apiToken
)
```

### Using the Token for 3DS Authentication

The OTT token can also be used for 3DS authentication:

```swift
import DataMPGS3ds

let threeDSRequest = MPGS3dsReq(
    amount: "100.00",
    currency: "AUD",
    threeDS: MPGS3dsData(browserDetails: MPGS3dsBrowserDetails()),
    token: ottToken // Use the token from PaymentSourcesService
)

let mpgs3dsService: MPGS3dsService = MPGS3dsServiceImpl()
let threeDSToken = try await mpgs3dsService.createMPGS3dsToken(
    request: threeDSRequest,
    apiAccessToken: apiToken
)
```

## API Endpoints

- `POST /v1/payment_sources/tokens` - Create an OTT token from payment source details

## Response Structure

The `OTTTokenRes` includes:
- `status`: HTTP status code (typically 201)
- `error`: Error information (if any)
- `resource`: Token resource containing:
  - `type`: Resource type ("token")
  - `data`: The OTT token string (UUID format)

## Security Notes

- **Never store card details** on the client side
- **Always use HTTPS** when transmitting card details
- **Use OTT tokens** for one-time payment processing
- **Convert to vault tokens** if you need to store payment methods for future use (see `DataVault` package)

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


