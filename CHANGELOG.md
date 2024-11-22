# Changelog

## [1.5.0] - 2024-11-22

### Added

- `PayPalSavePaymentSourceWidget` added to the SDK
- `PayPalDataCollectorUtil` added to the SDK

### Changed

- Updated NetworkingLib to `1.2.0`
- Button based Widgets now have flexible height

### Fixed

 - TextField validations not triggering on iOS 18

## [1.4.0] - 2024-10-18

### Added

- `collectCardholderName` flag added to `CardDetailsWidget`

## [1.3.1] - 2024-10-01

### Fixed

 - Outer Package mismatch with SDK Package

## [1.3.0] - 2024-09-27

### Added

- `enableTestMode` flag to `MobileSDKConfig` initialisation 
- `transactionCanceled` to FlyPay and PayPal

### Changed

- Updated NetworkLib to `1.1.0`

### Fixed

- Checkout Example flow(s) for card details
- Expiry and CVV alignment issues
- Scroll issue on WebViews
- Presenting Afterpay SDK with top VC
- FlyPay Url and redirect Url
- PayPal redirect Url
- iOS 18: Fixed checkout sheet

### Compatibility
- Tested support against iOS 18
- Removed support for iOS 16

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

