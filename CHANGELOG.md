# Changelog

## [1.3.0] - 2024-09-25

### Added

- `enableTestMode` flag to `MobileSDKConfig` initialisation 

### Changed

- Updated NetworkLib to `1.1.0`

### Fixed

- Checkout Example flow(s) for card details
- Expiry and CVV alignment issues
- Scroll issue on WebViews
- Presenting Afterpay SDK with top VC
- FlyPay Url and redirect Url
- PayPal redirect Url

## [1.2.5] - 2024-08-28

### Fixed

- Package sources for SDK `Package.swift`

## [1.2.0] - 2024-08-22

### Added

- Access token functionality to widget contracts
- Moved network logic into separate dependency module

### Changed

- Card widget input field error label(s) update
- Removed `publicKey` functionality, in place of `accessToken`
- Renamed "MastercardSRC" to "ClickToPay"
- Improved error handling for WebView and NetworkLib
- Added initial loader state to WebView (3DS & ClickToPay)

