//
//  LoadingDelegate.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

public protocol WidgetLoadingDelegate: AnyObject {
    func loadingDidStart()
    func loadingDidFinish()
}
