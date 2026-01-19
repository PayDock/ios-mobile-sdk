# DataCustomer

A Swift Package for handling customer-related API operations in the Paydock iOS SDK.

## Overview

`DataCustomer` provides request/response models, endpoints, and services for creating and managing customers through the Paydock API. This package allows you to create customer records with associated payment sources.

## Contents

### Requests
- **`CreateCustomerTokenReq`**: Request model for POST `/v1/customers` - creating a customer with a payment source token

### Responses
- **`CreateCustomerTokenRes`**: Response model for customer creation operations

### Services
- **`CustomersService`**: Protocol and implementation for customer-related API calls
- **`CustomersServiceImpl`**: Default implementation of `CustomersService`

### Endpoints
- **`CustomersEndpoints`**: Enum defining customer-related API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ChargePaymentSource`)

## Usage

### Importing

```swift
import DataCustomer
```

### Initializing the Service

```swift
let customersService: CustomersService = CustomersServiceImpl()
```

### Creating a Customer

```swift
let request = CreateCustomerTokenReq(
    token: "vault-token-123", // Payment source vault token
    firstName: "John",
    lastName: "Doe",
    email: "john.doe@example.com",
    phone: "+61412345678",
    externalId: "customer-123",
    suspicious: false,
    paymentSource: ChargePaymentSource(
        gatewayId: "gateway-123",
        vaultToken: "vault-token-123",
        addressLine1: "123 Main St",
        addressCity: "Sydney",
        addressPostcode: "2000",
        addressState: "NSW",
        addressCountry: "AU"
    )
)

do {
    let response = try await customersService.createCustomer(
        request: request,
        apiAccessToken: "your-api-token"
    )
    print("Customer created: \(response.resource.data.id)")
    print("Customer token: \(response.resource.data.token)")
} catch {
    print("Error: \(error)")
}
```

### Creating a Customer with Minimal Information

```swift
let minimalRequest = CreateCustomerTokenReq(
    token: "vault-token-456"
)

do {
    let response = try await customersService.createCustomer(
        request: minimalRequest,
        apiAccessToken: "your-api-token"
    )
    print("Customer created: \(response.resource.data.id)")
} catch {
    print("Error: \(error)")
}
```

## API Endpoints

- `POST /v1/customers` - Create a new customer

## Response Structure

The `CreateCustomerTokenRes` includes:
- `status`: HTTP status code
- `error`: Error information (if any)
- `errorSummary`: Detailed error summary (if any)
- `resource`: Customer resource containing:
  - `type`: Resource type ("customer")
  - `data`: Customer data including:
    - `id`: Customer ID
    - `token`: Customer token
    - `firstName`, `lastName`, `email`, `phone`: Customer details
    - `paymentSource`: Associated payment source information

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


