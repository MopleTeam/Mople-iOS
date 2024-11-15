//
//  UIScreen+NotchSize.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension UIScreen {
    static func hasNotch() -> Bool {
        return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
    }
}
