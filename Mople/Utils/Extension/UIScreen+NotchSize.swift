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
    
    /// 노치 유무에 따라서 띄울 거리
    /// - 노치 O : 기본적으로 노치사이즈만큼 띄워져 있음으로 0
    /// - 노치 X : 화면의 끝과 맞닿아 있음으로 기본 사이즈(28)
    static func getDefatulBottomInset() -> CGFloat {
        return hasNotch() ? 0 : defaultBottomInset
    }
    
    static func getNotchSize() -> CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    
    static func hasNotch() -> Bool {
        return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0
    }
}
