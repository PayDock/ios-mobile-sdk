# DataCharges

A Swift Package for handling charge-related API operations in the Paydock iOS SDK.

## Overview

`DataCharges` provides request/response models, endpoints, and services for creating and managing charges through the Paydock API. This includes wallet charges, standard charges, and charge capture operations.

## Contents

### Requests
- **`CaptureChargeReq`**: Request model for POST `/v1/charges` - creating a standard charge
- **`CaptureChargeStandaloneReq`**: Request model for POST `/v1/charges` - capturing a standalone 3DS charge
- **`InitialiseWalletChargeReq`**: Request model for POST `/v1/charges/wallet` - initializing wallet charges (Apple Pay, Google Pay, PayPal, etc.)

### Responses
- **`CaptureChargeRes`**: Response model for charge creation operations
- **`InitialiseWalletChargeRes`**: Response model for wallet charge initialization

### Services
- **`ChargesService`**: Protocol and implementation for charge-related API calls
- **`ChargesServiceImpl`**: Default implementation of `ChargesService`

### Endpoints
- **`ChargesEndpoints`**: Enum defining all charge-related API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ChargePaymentSource`)

## Usage

### Importing

```swift
import DataCharges
```

### Initializing the Service

```swift
let chargesService: ChargesService = ChargesServiceImpl()
```

### Creating a Standard Charge

```swift
let request = CaptureChargeReq(
    amount: "100.00",
    currency: "AUD",
    reference: "order-123",
    description: "Purchase order",
    customer: ChargeCustomer(
        firstName: "John",
        lastName: "Doe",
        email: "john.doe@example.com",
        paymentSource: ChargePaymentSource(
            vaultToken: "vault-token-123"
        )
    )
)

do {
    let response = try await chargesService.captureCharge(
        request: request,
        apiAccessToken: "your-api-token"
    )
    print("Charge created: \(response.data.id)")
} catch {
    print("Error: \(error)")
}
```

### Initializing a Wallet Charge

```swift
let walletRequest = InitialiseWalletChargeReq(
    customer: InitialiseWalletChargeCustomer(
        firstName: "Jane",
        lastName: "Smith",
        email: "jane@example.com",
        phone: "+61412345678",
        paymentSource: InitialiseWalletChargePaymentSource(
            gatewayId: "gateway-123",
            walletType: "applepay"
        )
    ),
    amount: 100.00,
    currency: "AUD",
    reference: "order-456",
    meta: InitialiseWalletChargeMetaData(
        storeName: "My Store",
        merchantName: "My Merchant",
        storeId: "store-123"
    )
)

do {
    let token = try await chargesService.initialiseWalletCharge(
        initializeWalletChargeReq: walletRequest,
        apiAccessToken: "your-api-token"
    )
    print("Wallet token: \(token)")
} catch {
    print("Error: \(error)")
}
```

### Capturing a Coles Pay Charge

```swift
do {
    let response = try await chargesService.captureChargeColesPay(
        chargeId: "charge-id-123",
        apiAccessToken: "your-api-token"
    )
    print("Charge captured: \(response.data.id)")
} catch {
    print("Error: \(error)")
}
```

## API Endpoints

- `POST /v1/charges/wallet` - Initialize wallet charge
- `POST /v1/charges` - Create/capture charge
- `POST /v1/charges/{id}/capture` - Capture a pre-authorized charge

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


