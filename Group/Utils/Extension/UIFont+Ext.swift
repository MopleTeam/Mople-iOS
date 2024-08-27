//
//  UIFont+Ext.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

extension UIFont {
    
    enum Pretendard: String {
        case black = "Pretendard-Black"
        case bold = "Pretendard-Bold"
        case semiBold = "Pretendard-SemiBold"
        case extraBold = "Pretendard-ExtraBold"
        case extraLight = "Pretendard-ExtraLight"
        case light = "Pretendard-Light"
        case medium = "Pretendard-Medium"
        case reqular = "Pretendard-Regular"
        case thin = "Pretendard-Thin"
    }
    
    static func pretendard(type: Pretendard, size: CGFloat) -> UIFont {
        
        if let customFont = self.init(name: type.rawValue, size: size) {
            return customFont
        } else {
            return .systemFont(ofSize: size)
        }
    }
    
}


