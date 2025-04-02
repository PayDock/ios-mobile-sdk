//
//  LoadingDelegate.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

@MainActor
public protocol WidgetLoadingDelegate: AnyObject {
    func loadingDidStart()
    func loadingDidFinish()
}
