//
//  ApplePayVMTests+Mapping.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.
//
//  Split out of ApplePayVMTests.swift to keep both files under the SwiftLint
//  file_length / type_body_length thresholds.

import XCTest
import PassKit
import Contacts
import Combine
@testable import MobileSDK
@testable import DataPaymentSources
@testable import NetworkingLib

extension ApplePayVMTests {

    // MARK: - Data Mapping (buildShipping / buildBilling)

    func testMapping_Shipping_FullContact_MapsAllFields() {
        let shipping = viewModel.buildShipping(from: makeContact())

        XCTAssertEqual(shipping?.addressLine1, "1 Main St")
        XCTAssertEqual(shipping?.addressLine2, "Unit 2")
        XCTAssertEqual(shipping?.addressCity, "Sydney")
        XCTAssertEqual(shipping?.addressState, "NSW")
        XCTAssertEqual(shipping?.addressPostcode, "2000")
        XCTAssertEqual(shipping?.addressCountry, "AU")
        XCTAssertEqual(shipping?.contact?.firstName, "Jane")
        XCTAssertEqual(shipping?.contact?.lastName, "Doe")
        XCTAssertEqual(shipping?.contact?.email, "jane@example.com")
        XCTAssertEqual(shipping?.contact?.phone, "+61400000000")
    }

    func testMapping_Shipping_MultiLineStreet_SplitsIntoLine1And2() {
        let shipping = viewModel.buildShipping(from: makeContact(street: "Line A\nLine B"))
        XCTAssertEqual(shipping?.addressLine1, "Line A")
        XCTAssertEqual(shipping?.addressLine2, "Line B")
    }

    func testMapping_NilContact_ReturnsNil() {
        XCTAssertNil(viewModel.buildShipping(from: nil))
        XCTAssertNil(viewModel.buildBilling(from: nil))
    }

    func testMapping_Billing_MapsAddressFields() {
        let billing = viewModel.buildBilling(from: makeContact())
        XCTAssertEqual(billing?.addressLine1, "1 Main St")
        XCTAssertEqual(billing?.addressLine2, "Unit 2")
        XCTAssertEqual(billing?.addressCity, "Sydney")
        XCTAssertEqual(billing?.addressState, "NSW")
        XCTAssertEqual(billing?.addressPostcode, "2000")
        XCTAssertEqual(billing?.addressCountry, "AU")
    }

    // MARK: - Payload

    func testPayload_IsBase64OfSnakeCaseJSON() throws {
        let shipping = viewModel.buildShipping(from: makeContact())
        let result = viewModel.makeApplePayPayload(
            shipping: shipping, billing: nil, cardScheme: "visa", refToken: "ref-123")

        guard case .success(let base64) = result else { return XCTFail("expected success payload") }
        let data = try XCTUnwrap(Data(base64Encoded: base64))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        // snake_case keys present
        XCTAssertEqual(json["ref_token"] as? String, "ref-123")
        XCTAssertNotNil(json["card_info"])
        XCTAssertNotNil(json["shipping"])
    }

    // MARK: - Token creation (value-based)

    func testCreateOTTToken_Success_EmitsResult() async {
        mockPaymentSourcesService.applePayTokenResult = "ott-success-1"
        setupViewModel(service: mockPaymentSourcesService)

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "visa", refToken: "ref")

        XCTAssertEqual(viewModel.paymentStatus, .success)
        XCTAssertEqual(viewModel.result?.ottToken, "ott-success-1")
        XCTAssertEqual(viewModel.result?.cardInfo?.cardScheme, "visa")
        XCTAssertNil(viewModel.error)
    }

    func testCreateOTTToken_RequestError_MapsToErrorCreatingToken() async {
        mockPaymentSourcesService.shouldReturnError = true
        mockPaymentSourcesService.errorToReturn = ErrorRes(
            status: 400,
            error: .init(message: "boom", code: "E", details: nil),
            resource: nil, errorSummary: nil)
        setupViewModel(service: mockPaymentSourcesService)

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")

        XCTAssertEqual(viewModel.paymentStatus, .failure)
        guard case .errorCreatingToken(let err) = viewModel.error else { return XCTFail("expected errorCreatingToken") }
        XCTAssertEqual(err.error?.message, "boom")
    }

    func testCreateOTTToken_UnknownThrow_MapsToUnknownError() async {
        mockPaymentSourcesService.shouldThrowUnknownError = true
        setupViewModel(service: mockPaymentSourcesService)

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")

        XCTAssertEqual(viewModel.paymentStatus, .failure)
        guard case .unknownError = viewModel.error else { return XCTFail("expected unknownError") }
    }

    /// Simulates the response schema drifting from `ApplePayTokenRes` (renamed/missing/retyped
    /// field). The networking layer catches the `DecodingError` and rethrows it as
    /// `RequestError.decode` (see `HTTPClient.sendRequest`), so the VM maps it to
    /// `.unknownError(RequestError.decode)`. Crucially, the surfaced error must carry the stable,
    /// identifiable code `APPLE_PAY_RESPONSE_DECODE` so integrators can log/report it.
    func testCreateOTTToken_ResponseDecodeFailure_IsIdentifiable() async {
        mockPaymentSourcesService.applePayErrorToThrow = RequestError.decode(nil)
        setupViewModel(service: mockPaymentSourcesService)

        await viewModel.createOTTToken(shipping: nil, billing: nil, cardScheme: "", refToken: "")

        XCTAssertEqual(viewModel.paymentStatus, .failure)
        guard case .unknownError(let underlying) = viewModel.error else {
            return XCTFail("expected unknownError")
        }
        // The underlying RequestError.decode is preserved (not discarded)...
        guard case .decode = underlying else {
            return XCTFail("expected the wrapped RequestError to be .decode")
        }
        // ...and surfaces as a distinct, stable code the integrator can key on.
        XCTAssertEqual(viewModel.error?.code, "APPLE_PAY_RESPONSE_DECODE")
    }

    // MARK: - Availability / gating

    func testAvailabilityChecksEnabled_ReflectsConfig() {
        XCTAssertTrue(viewModel.availabilityChecksEnabled) // default config
        setupViewModel(performAvailabilityChecks: false)
        XCTAssertFalse(viewModel.availabilityChecksEnabled)
    }

    func testShouldShowSetupButton_DeviceUnsupported_FiresNotSupported_ReturnsFalse() {
        let checker = FakeAvailabilityChecker(deviceSupports: false)
        setupViewModel(checker: checker, showSetup: true)

        XCTAssertFalse(viewModel.shouldShowSetupButton())
        guard case .failure(.notSupported)? = completionResult else { return XCTFail("expected .notSupported") }
    }

    func testShouldShowSetupButton_SupportedNoCards_SetupEnabled_ReturnsTrue_FiresNoSupportedCards() {
        let checker = FakeAvailabilityChecker(deviceSupports: true, defaultNetworks: false)
        setupViewModel(checker: checker, showSetup: true)

        XCTAssertTrue(viewModel.shouldShowSetupButton())
        // Current behaviour: fires noSupportedCardsInWallet even while showing the setup button
        guard case .failure(.noSupportedCardsInWallet)? = completionResult else {
            return XCTFail("expected .noSupportedCardsInWallet")
        }
    }

    func testShouldShowSetupButton_SupportedNoCards_SetupDisabled_ReturnsFalse() {
        let checker = FakeAvailabilityChecker(deviceSupports: true, defaultNetworks: false)
        setupViewModel(checker: checker, showSetup: false)
        XCTAssertFalse(viewModel.shouldShowSetupButton())
    }

    func testShouldShowSetupButton_CardsAlreadyEnrolled_ReturnsFalse() {
        let checker = FakeAvailabilityChecker(deviceSupports: true, defaultNetworks: true)
        setupViewModel(checker: checker, showSetup: true)
        XCTAssertFalse(viewModel.shouldShowSetupButton())
    }

    func testCanMakePaymentsWithConfiguredNetworks_UsesChecker() {
        setupViewModel(checker: FakeAvailabilityChecker(deviceSupports: true, canMakeForRequest: true))
        XCTAssertTrue(viewModel.canMakePaymentsWithConfiguredNetworksAndCapabilities())
        setupViewModel(checker: FakeAvailabilityChecker(deviceSupports: true, canMakeForRequest: false))
        XCTAssertFalse(viewModel.canMakePaymentsWithConfiguredNetworksAndCapabilities())
    }

    // MARK: - Present fail (deterministic via fake presenter)

    func testStartPayment_PresentFails_FiresUnableToPresent_ResetsProcessing() async {
        let expectation = XCTestExpectation(description: "present-fail completion")
        viewModel = ApplePayVM(
            config: makeConfig(),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            presenterFactory: FakePresenterFactory(presentSuccess: false),
            completion: { result in
                self.completionResult = result
                expectation.fulfill()
            })
        viewModel.isProcessing = true

        viewModel.startPayment()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertFalse(viewModel.isProcessing)
        guard case .failure(.unableToPresentPaymentSheet)? = completionResult else {
            return XCTFail("expected .unableToPresentPaymentSheet")
        }
    }

    // MARK: - Shipping callbacks

    func testDidSelectShippingContact_WithHandler_UsesCustomUpdate() async {
        let expectation = XCTestExpectation(description: "shipping contact handler")
        var handlerCalled = false
        viewModel = ApplePayVM(
            config: makeConfig(),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            onShippingContactSelected: { _ in
                handlerCalled = true
                return PKPaymentRequestShippingContactUpdate(paymentSummaryItems: [])
            },
            completion: { _ in })

        viewModel.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didSelectShippingContact: PKContact()) { _ in
                XCTAssertTrue(handlerCalled)
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testDidSelectShippingContact_NoHandler_StillCallsHandler() async {
        let expectation = XCTestExpectation(description: "default shipping contact update")
        // Default setup has no onShippingContactSelected
        viewModel.paymentAuthorizationController(
            PKPaymentAuthorizationController(),
            didSelectShippingContact: PKContact()) { _ in
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    // MARK: - Config

    func testConfig_Defaults() {
        let config = ApplePayWidgetConfig(
            serviceId: "s", accessToken: "t", pkPaymentRequest: PKPaymentRequest())
        XCTAssertFalse(config.showSetUpButtonWhenNoCardsEnrolled)
        XCTAssertTrue(config.performAvailabilityChecks)
    }

    // MARK: - Edge Cases

    func testCompletion_IsCalledOnlyOnce() {
        var completionCount = 0
        viewModel = ApplePayVM(
            config: makeConfig(),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            completion: { _ in completionCount += 1 })

        // Two terminal signals for the same flow must still fire completion exactly once
        // (guarded by isCompletionCalled in callCompletion).
        viewModel.finishAndComplete()
        viewModel.finishAndComplete()

        XCTAssertEqual(completionCount, 1)
    }

    func testCompletion_PresentFailThenFinish_FiresOnce() async {
        let firstCompletion = XCTestExpectation(description: "first completion")
        var completionCount = 0
        viewModel = ApplePayVM(
            config: makeConfig(),
            eventDelegate: eventDelegate,
            paymentSourcesService: mockPaymentSourcesService,
            presenterFactory: FakePresenterFactory(presentSuccess: false),
            completion: { _ in
                completionCount += 1
                firstCompletion.fulfill()
            })

        // Present fails -> fires .unableToPresentPaymentSheet completion.
        viewModel.startPayment()
        await fulfillment(of: [firstCompletion], timeout: 2.0)
        // A subsequent terminal signal must not fire completion again.
        viewModel.finishAndComplete()

        XCTAssertEqual(completionCount, 1)
    }

    // MARK: - Helper Methods

    fileprivate func makeConfig(showSetup: Bool = false,
                                performAvailabilityChecks: Bool = true) -> ApplePayWidgetConfig {
        ApplePayWidgetConfig(
            serviceId: "test-service-id",
            accessToken: "test-widget-token",
            pkPaymentRequest: PKPaymentRequest(),
            showSetUpButtonWhenNoCardsEnrolled: showSetup,
            performAvailabilityChecks: performAvailabilityChecks)
    }

    fileprivate func setupViewModel(service: PaymentSourcesMockService? = nil,
                                    checker: ApplePayAvailabilityChecking = DefaultApplePayAvailabilityChecker(),
                                    showSetup: Bool = false,
                                    performAvailabilityChecks: Bool = true) {
        completionResult = nil
        viewModel = ApplePayVM(
            config: makeConfig(showSetup: showSetup, performAvailabilityChecks: performAvailabilityChecks),
            eventDelegate: eventDelegate,
            paymentSourcesService: service ?? mockPaymentSourcesService,
            availabilityChecker: checker,
            completion: { result in self.completionResult = result })
    }

    fileprivate func makeContact(street: String = "1 Main St\nUnit 2") -> PKContact {
        let contact = PKContact()
        var name = PersonNameComponents()
        name.givenName = "Jane"
        name.familyName = "Doe"
        contact.name = name
        contact.emailAddress = "jane@example.com"
        contact.phoneNumber = CNPhoneNumber(stringValue: "+61400000000")
        let address = CNMutablePostalAddress()
        address.street = street
        address.city = "Sydney"
        address.state = "NSW"
        address.postalCode = "2000"
        address.isoCountryCode = "AU"
        contact.postalAddress = address
        return contact
    }
}

// MARK: - Test doubles

private final class FakeAvailabilityChecker: ApplePayAvailabilityChecking {
    var deviceSupports: Bool
    var defaultNetworks: Bool
    var canMakeForRequest: Bool

    init(deviceSupports: Bool = true, defaultNetworks: Bool = true, canMakeForRequest: Bool = true) {
        self.deviceSupports = deviceSupports
        self.defaultNetworks = defaultNetworks
        self.canMakeForRequest = canMakeForRequest
    }

    func deviceSupportsApplePay() -> Bool { deviceSupports }
    func canMakePaymentsWithDefaultNetworks() -> Bool { defaultNetworks }
    func canMakePayments(for request: PKPaymentRequest) -> Bool { canMakeForRequest }
}

private final class FakePaymentPresenter: PaymentAuthorizationPresenting {
    var delegate: PKPaymentAuthorizationControllerDelegate?
    private let presentSuccess: Bool
    init(presentSuccess: Bool) { self.presentSuccess = presentSuccess }
    func present(completion: @escaping (Bool) -> Void) { completion(presentSuccess) }
}

private struct FakePresenterFactory: PaymentAuthorizationPresenterFactory {
    let presentSuccess: Bool
    func makePresenter(for request: PKPaymentRequest) -> PaymentAuthorizationPresenting {
        FakePaymentPresenter(presentSuccess: presentSuccess)
    }
}
