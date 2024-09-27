//
//  File.swift
//  
//
//  Created by Ricardo Da Silva on 2024/09/16.
//

import SwiftUI

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        guard let keyWindow = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return nil
        }

        var topController = keyWindow.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
}
