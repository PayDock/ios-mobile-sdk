# CommonModels

A shared Swift Package containing common data models used across multiple Paydock API packages.

## Overview

`CommonModels` provides shared data structures that are used by multiple domain-specific packages. This package contains models that are reused across different API endpoints to avoid duplication and ensure consistency.

## Contents

### Models

- **`ChargePaymentSource`**: Payment source information structure shared across multiple API requests. Used in charge requests, customer creation, and other payment operations.
- **`ErrorSummary`**: Error summary structure containing error details and messages from API responses.
- **`ErrorSummaryDetails`**: Detailed error information including path and messages.

## Dependencies

- `Foundation` (standard library)

## Usage

### Importing

```swift
import CommonModels
```

### Using ChargePaymentSource

```swift
import CommonModels

let paymentSource = ChargePaymentSource(
    gatewayId: "gateway-123",
    vaultToken: "vault-token-456",
    addressLine1: "123 Main St",
    addressCity: "Sydney",
    addressPostcode: "2000",
    addressCountry: "AU"
)
```

### Using ErrorSummary

```swift
import CommonModels

// ErrorSummary is typically returned in API error responses
if let errorSummary = response.errorSummary {
    print("Error: \(errorSummary.message)")
    print("Code: \(errorSummary.code)")
}
```

## Integration

This package is automatically imported as a dependency by other Paydock API packages:
- `DataCharges`
- `DataCustomer`
- `DataMPGS3ds`
- `DataPaymentSources`
- `DataStandalone3ds`
- `DataVault`

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


