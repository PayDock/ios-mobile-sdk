# DataGateways

A Swift Package for handling gateway-related API operations in the Paydock iOS SDK.

## Overview

`DataGateways` provides endpoints and services for retrieving gateway configuration information, specifically used for PayPal Vault client ID retrieval.

## Contents

### Responses
- **`PayPalVaultConfigRes`**: Response model for gateway wallet configuration retrieval
- **`PayPalVaultCallbackData`**: PayPal Vault callback data structure containing credentials

### Services
- **`GatewayService`**: Protocol and implementation for gateway API calls
- **`GatewayServiceImpl`**: Default implementation of `GatewayService`

### Endpoints
- **`GatewayEndpoints`**: Enum defining gateway API endpoints

## Dependencies

- `NetworkingLib`: Core networking library for HTTP requests
- `CommonModels`: Shared models (e.g., `ErrorSummary`)

## Usage

### Importing

```swift
import DataGateways
```

### Initializing the Service

```swift
let gatewayService: GatewayService = GatewayServiceImpl()
```

### Getting PayPal Vault Client ID

```swift
do {
    let clientId = try await gatewayService.getClientId(
        gatewayId: "gateway-123",
        widgetAccessToken: "your-widget-access-token"
    )
    print("PayPal Client ID: \(clientId)")
} catch {
    print("Error: \(error)")
}
```

## API Endpoints

- `GET /v1/gateways/{gatewayId}/wallet-config` - Retrieve gateway wallet configuration (PayPal Vault client ID)

## Response Structure

The `PayPalVaultConfigRes` includes:
- `status`: HTTP status code
- `resource`: Resource containing:
  - `type`: Resource type
  - `data`: Configuration data including:
    - `type`: Configuration type
    - `mode`: Configuration mode
    - `credentials`: Credentials containing:
      - `clientAuth`: PayPal client authentication ID

## Requirements

- iOS 16.0+
- Swift 5.7+

## License

Copyright © 2026 Paydock Ltd. All rights reserved.


