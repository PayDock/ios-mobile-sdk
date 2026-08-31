# Changelog

## [4.6.0] - 2026-08-27

### Added
- Added `showSubmitButton` to `CardDetailsWidgetConfig` and `GiftCardWidgetConfig` (default `true`).
  When `false`, the widget hides its own built-in submit button entirely, so a host app can supply its own trigger UI. `CardDetailsWidget` and `GiftCardWidget` gain new init parameters to support this: `submitTrigger: Binding<Bool>` and `onFormValidityChange: ((Bool) -> Void)?` (fired whenever the form's validity changes).
- Added `showSchemeList` to `SupportedSchemesConfig` (default `true`). When `false`, `CardDetailsWidget` hides its row of supported card scheme icons entirely, regardless of `supportedSchemes`.
- Added `activePrimaryButton` to `GiftCardWidgetConfig` and `AddressWidgetConfig` (matching
  `CardDetailsWidgetConfig`). When `true`, the primary button stays enabled and validation runs on tap, including a VoiceOver "N errors in form" summary and focus moving to the first invalid field; when `false`, the button remains disabled until the form is valid.
- Per-field text-field theming for `GiftCardWidget` and `AddressWidget`, matching `CardDetailsWidget`.
  `GiftCardWidgetAppearance` gains optional `cardNumberTextField` / `pinTextField`; `AddressWidgetAppearance`
  gains optional `firstNameTextField`, `lastNameTextField`, `addressLine1TextField`, `addressLine2TextField`,
  `cityTextField`, `stateTextField`, `postcodeTextField`. Each falls back to the shared `textField` when
  `nil`, so existing configurations are unaffected. `AddressWidgetAppearance`'s per-field overrides default
  to `nil`; `GiftCardWidgetAppearance`'s `cardNumberTextField` / `pinTextField` default to a seeded
  appearance carrying the field's default placeholder/hint text (see below) rather than `nil`, so the
  effective values are discoverable via the appearance object (e.g. in a styling screen) instead of only
  as fallbacks inside the widget's rendering code. Pass `nil` explicitly to opt out.
- `GiftCardWidget` now shows field placeholders ("XXXX XXXX XXXX XXXX", "XXXX") and hints, and exposes
  digit-by-digit VoiceOver values plus per-field accessibility identifiers (`giftCardNumberField`,
  `giftCardPinField`).
- `AddressWidget` now exposes per-field accessibility identifiers (`firstNameField`, `lastNameField`,
  `addressLine1Field`, `addressLine2Field`, `cityField`, `stateField`, `postcodeField`).
- `GiftCardWidget` and `AddressWidget` now announce validation errors via VoiceOver as they occur,
  matching `CardDetailsWidget`.

### Changed
- Bumped `ios-core-networking` dependency to `1.3.0` (adds `DecodingFailureContext` on
  `RequestError.decode`; `.decode` now has an associated value).
- **Breaking:** `AddressWidgetAppearance.init` parameter labels renamed for consistency with the property
  names and the other widgets: `textfield:` → `textField:`, `primaryButton:` → `actionButton:`,
  `linkButton:` → `expandSectionButton:`. Call sites that passed these labels must be updated; property
  names are unchanged.
- **Behaviour change:** `GiftCardWidget` and `AddressWidget` now default to `activePrimaryButton: true`
  (matching `CardDetailsWidget`), so their primary button is enabled from the start and validates on tap
  rather than staying disabled until the form is valid. Pass `activePrimaryButton: false` in the config
  to restore the previous disabled-until-valid behaviour.
- Removed unused placeholder constants on `GiftCardFormManager` (`cardNumberPlaceholder`, `pinPlaceholder`) and
  `AddressFormManager` (the nine `*Placeholder` constants) — placeholders are now configured via the
  widget appearance.

### Fixed
- `GiftCardWidget`'s re-entrancy guard against double-submission relied on `isLoading`, which
  `GiftCardVM` never updated when a `loadingDelegate` was supplied — a host using a `loadingDelegate`
  had no protection against a double-tap or overlapping `submitTrigger` call. `isLoading` is now always
  kept accurate regardless of delegate presence (a new `showLoaders` flag, matching `CardDetailsWidget`,
  now separately controls whether the internal button's own spinner renders when a delegate is present).
- `CardDetailsWidget` and `GiftCardWidget`'s `submitTapped()` now also blocks while the widget has been
  externally disabled via `ViewState.setState(.disabled)`, not just while a request is in flight —
  previously the external `submitTrigger` path ignored that host-initiated disable entirely.
- Both widgets now guard against re-entrancy synchronously in the view model (`tokeniseCardDetails()`/
  `tokeniseGiftCard()`), rather than relying solely on the view layer's guard, closing a narrow window
  where two calls arriving before the first `Task` had started could both proceed.

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

