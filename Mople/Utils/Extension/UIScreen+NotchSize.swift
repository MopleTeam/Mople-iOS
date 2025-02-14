//
//  UIScreen+NotchSize.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension UIScreen {
    
    static let defaultBottomInset: CGFloat = 28

    /// 기본 바텀 인셋
    /// - 노치 O : 노치 사이즈
    /// - 노치 X : 기본 사이즈 (28)
    static func getBottomSafeAreaHeight() -> CGFloat {
        return hasNotch() ? getNotchSize() : defaultBottomInset
    }

    static func getNotchSize() -> CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    
    static func hasNotch() -> Bool {
        return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
    }
}
