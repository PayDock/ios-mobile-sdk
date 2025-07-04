//
//  GlobalTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2024 Paydock Ltd.
//

public class GlobalTheme {
    
    public var globalTheme: Theme
    
    public static let shared = GlobalTheme()
    
    private init() {
        self.globalTheme = Theme()
    }
}
