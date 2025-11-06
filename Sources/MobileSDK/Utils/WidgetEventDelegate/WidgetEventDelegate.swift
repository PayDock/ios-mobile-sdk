//
//  WidgetEventDelegate.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

@MainActor
public protocol WidgetEventDelegate: AnyObject {

    func widgetEvent(event: WidgetEvent)
}
