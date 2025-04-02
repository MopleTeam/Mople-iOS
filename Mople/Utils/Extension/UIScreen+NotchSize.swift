//
//  UIScreen+NotchSize.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension UIScreen {
    
    private static let defaultBottomInset: CGFloat = 28
    
    private static func getNotchSize() -> CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }

    /// 기본 바텀 패딩
    /// - 바텀 패딩이 자동으로 조정되지 않는 경우를 위해 기본 패딩를 지정
    static func getDefaultBottomPadding() -> CGFloat {
        return hasNotch() ? getNotchSize() : defaultBottomInset
    }
    
    
    /// Bottom Safe 높이
    /// - 바텀 패딩이 자동으로 조정되는 경우
    ///     - 노치가 있는 경우 추가 조정필요 없음
    ///     - 노치가 없는 경우엔 패딩필요
    static func getSafeBottomHeight() -> CGFloat {
        return hasNotch() ? 0 : defaultBottomInset
    }

    static func hasNotch() -> Bool {
        return getNotchSize() > 0
    }
}
