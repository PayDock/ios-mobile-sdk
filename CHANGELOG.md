# Changelog

## [4.5.0] - 2026-06-16

### Added
- New 'ApplePaySetupWidget' to send users to wallet setup
- New Apple Pay helper functions to identify availability accessible from "MobileSDK", "deviceSupportsApplePay" and "canMakeApplePayPayments"
- Added "activePrimaryButton" to 'CardDetailsWidgetConfig' which defaults to "true" to allow submit button to be actionable when fields do not yet have valid entries
- New customisable "hintText" field for textfields in 'CardDetailsWidget'
- Added Voiceover readout for 'CardDetailsWidget' for validation errors on submit
- Added scroll callback "onScrollToField" for 'CardDetailsWidget' to allow scrolling to validation error when off screen
- Added VoiceOver readouts for fields that are required in a form
- Added accessibility options in styles for custom VoiceOver readouts
- "formState" added to 'CardDetailsWidget' event 'WidgetEvent' on submit action
- 'Standalone3dsWidget' now uses a new overlay loader component
- Added a "loadingDelegate" to 'Standalone3dsWidget' for custom loader control

### Fixed
- "placeholderText" was not being shown in Textfields correctly

## [4.4.0] - 2026-04-10

### Added
- New error in 'ApplePayWidget' for "notSupported" if Apple Pay is not supported on device
- New error in 'ApplePayWidget' for "noSupportedCardsInWallet" if no cards are enrolled in Apple Pay for specific config passed
- Result for 'ApplePayWidget' updated to return shipping and billing details
- Callbacks added in 'ApplePayWidget' for contact and shipping details callbacks

### Changed
- 'ApplePayWidget' now returns a result object with a token versus previously completing the charge

### Fixed
- Removed 'PayPalVaultAppearance' overwriting appearance passed in init
- Minimum card number length for unknown card schemes updated to 13

## [4.3.0] - 2026-03-13

### Added

- Implemented 'ZipWidget' for Zip Money support
- Disabled state alpha configurable for button appearance
- Added config page to sample app

### Changed

- Updated bin processing for 'CardDetailsWidget'
- Updated form validations for 'CardDetailsWidget' and 'GiftCardWidget'
- Security code and Pin code entry in 'CardDetailsWidget' and 'GiftCardWidget' now use secure Textfields
- Saving of CVV now configurable for 'CardDetailsWidget'
- Removed title field for `CardDetailsWidget`
- Removed legacy "Solo" and "AUSBC" from supported card schemes for 'CardDetailsWidget'
- Removde autocorrect for cardholder name for 'CardDetailsWidget'
- Updated Amex card scheme icon for 'CardDetailsWidget'
- Font for widgets now defaults to system font
- Improved NSError mappings to readable strings

## [4.2.1] - 2026-02-06

### Fixed
- Standalone 3ds: Ignore non fatal issues in webview navigation

## [4.2.0] - 2025-11-25

### Added

- UnionPay support for card schemes
- Callbacks for info events to enable analytical collection
- Customisation options: spacing control for input form widgets (widget + input spacing)
- Updated checkout implementation for ExampleApp (demo app - E2E flows)
- CardDetailsWidget toggle enhanced styling options

### Changed

- Updated PayPal SDK from version 2.0.0 to 2.0.1
- Text and Icon customisation moved into appearance objects for SDK button widgets (ie. PayPalSavePaymentSourceWidget, CardDetailsWidget, AddressDetailsWidget and GiftCardWidget)
- Updated logic for no card scheme detection - applying default validation
- Search address popup positioning

### Fixed
- Accessibility improvements: Large Text support across widgets, scalable button and text field sizes,
- Payment methods: PayPal cancellation not being detected
- ColesPay widget closing and back to store cancellation
- Apple Pay infinite loader for some errors
- UI/UX: input field text vertical centering, disabled button styling, Click to Pay WebView session management, and app theme persistence on device rotation
- Hardcoded paddings to various UI elements

## [4.1.0] - 2025-10-03

### Changed

- Implemented native PayPal checkout flow using the latest PayPal SDK (`2.0.0`)
- Updated to use PayPal's native button; removed reliance on web views for PayPal
- Updated existing widget errors to propagate underlying network errors
- General improvements to `AddressWidget` (input UX and defaults)

### Fixed

- `AddressWidget` will now scroll active text field to prevent keyboard overlap
- `CardDetailsWidget` cursor positioning while editing card number and expiry fields
- `CardDetailsWidget` will now show approapriate keyboard type for each text field
- Security code validation not refreshing when switching between card schemes
- Cardholder name validation issues (including hyphen handling and invalid characters)
- `ColesPayWidget` will no longer get reset when changing device orientation
- `GiftCardWidget` PIN length validation

### Added

- Voiceover readouts for various loading states across the widgets

### Removed

- All WebView dependencies related to PayPal checkout

## [4.0.0] - 2025-07-04

### Added

- New customisations for all Widgets with `Appearance` added to all Widget contracts

### Changed

- `config` parameter standardised to all Widget contracts
- Handling of token callback results for Wallets now within SDK processing
- Coles Pay redirects to success without showing success landing page

### Fixed

- Address Widget popup will now disappear when search text is removed

## [3.1.0] - 2025-05-23

### Added

- Added cancelation confirmation prompt across the widgets
- Added charge flow for ColesPay widget in the example checkout

### Changed

- Rebranded FlyPay to Coles Pay
- Gift Card pin validation logic (minimum length 4)

### Fixed

- PayPal redirect cancellation flow from within the web view

## [3.0.0] - 2025-03-26

### Added

- Add support for high contrast accessibility colors.
- Add support for hardware and software keyboard navigation.
- Add support for autofill for the text fields in widgets.

### Removed

- Settings screen from sample app
- secretKey functionality in place of apiAccessToken

### Changed

- `Theme()` object now receives only a single color instead of the light mode and dark mode separately. Provided colors should have traits assigned to them.
- SDK default theme now supports light and dark mode along with the high contrast accessibility.
- Refactored ThreeDSWidget to Integrated3DSWidget and Standalone3DSWidget
- `PayPalDataCollectorUtil` calling function from `collectDeviceData()` to `collectDeviceId()`

### Fixed

- Various accessibility fixes and improvements.

## [2.1.1] - 2025-02-07

### Fixed

- Add missing BIN file resource to Package.swift

## [2.1.0] - 2025-02-04

### Added

- Voiceover support for widgets.
- Card validation is now based on the Paydock's supported BIN list.

### Changed

- Increased Client SDK version to v1.117.0.

## [2.0.0] - 2025-01-16

### Added

- New `CardDetailsWidgetConfig` to manage card details.
- Supported card scheme functionality (optional)
- Added accessibility font and UI scaling.

### Changed

- `CardDetailsWidget`contract with config.
- `CardDetailsWidget` now stores security code by default.
- Card scheme list matching supported schemes.
- Card security code validation is now based on card scheme.

## [1.8.0] - 2024-12-18

### Added

- Added option to `PayPalPaymentSourceWidget` to use custom icon in the button or no icon at all.

### Changed

- `PayPalPaymentSourceWidget` button will always have black border and text.
- Reverted button based Widgets to have a fixed height.

### Fixed

- Various fixes for `CardDetailsWidget` validations and focus states.

## [1.7.0] - 2024-12-06

### Added

- Added `AccountProfileView` as an example for collection of PayPal Vault token and creating of Customer

### Fixed

- PayPal Vault endpoints updated to work with latest changes

## [1.6.0] - 2024-11-29

### Added

- New `loadingDelegate` field added to `CardDetailsWidget`, `PayPalWidget` and `PayPalSavePaymentSourceWidget` for taking control of showing loaders
- New `viewState` field added to `CardDetailsWidget`, `PayPalWidget` and `PayPalSavePaymentSourceWidget` for externally controlling widget state

### Changed

- Separated `cornerRadius` into 2 parts (`textFieldCornerRadius` & `buttonCornerRadius`)

## [1.5.0] - 2024-11-22

### Added

- `PayPalSavePaymentSourceWidget` added to the SDK
- `PayPalDataCollectorUtil` added to the SDK

### Changed

- Updated NetworkingLib to `1.2.0`
- Button based Widgets now have flexible height.

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

