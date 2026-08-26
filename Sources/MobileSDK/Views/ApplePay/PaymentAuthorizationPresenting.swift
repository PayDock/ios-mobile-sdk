//
//  PaymentAuthorizationPresenting.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import PassKit

/// Abstraction over presenting the Apple Pay sheet, so the "present succeeded/failed" path can be
/// unit-tested without invoking the real system sheet. The default implementation wraps a real
/// `PKPaymentAuthorizationController`, so behaviour is unchanged in production.
protocol PaymentAuthorizationPresenting: AnyObject {
    var delegate: PKPaymentAuthorizationControllerDelegate? { get set }
    func present(completion: @escaping (Bool) -> Void)
}

/// Creates a presenter for a payment request. Injected so tests can supply a fake.
protocol PaymentAuthorizationPresenterFactory {
    func makePresenter(for request: PKPaymentRequest) -> PaymentAuthorizationPresenting
}

/// Production presenter backed by a real `PKPaymentAuthorizationController`. The wrapped controller
/// is the same instance PassKit hands back to the delegate, so `didFinish` can dismiss it.
final class DefaultPaymentAuthorizationPresenter: PaymentAuthorizationPresenting {
    private let controller: PKPaymentAuthorizationController

    init(request: PKPaymentRequest) {
        controller = PKPaymentAuthorizationController(paymentRequest: request)
    }

    var delegate: PKPaymentAuthorizationControllerDelegate? {
        get { controller.delegate }
        set { controller.delegate = newValue }
    }

    func present(completion: @escaping (Bool) -> Void) {
        controller.present(completion: completion)
    }
}

/// Production factory that creates `DefaultPaymentAuthorizationPresenter`s.
struct DefaultPaymentAuthorizationPresenterFactory: PaymentAuthorizationPresenterFactory {
    func makePresenter(for request: PKPaymentRequest) -> PaymentAuthorizationPresenting {
        DefaultPaymentAuthorizationPresenter(request: request)
    }
}
