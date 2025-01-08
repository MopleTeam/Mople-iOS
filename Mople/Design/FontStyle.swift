//
//  FontStyle.swift
//  Group
//
//  Created by CatSlave on 11/9/24.

import UIKit

struct FontStyle {
    enum Size {
        static let appTitle: CGFloat = 24
        static let heading: CGFloat = 22
        static let title: CGFloat = 20
        static let title2: CGFloat = 18
        static let title3: CGFloat = 16
        static let body1: CGFloat = 14
        static let body2: CGFloat = 12
        static let tabbar: CGFloat = 10
    }
    
    enum App {
        static let title: UIFont = .pretendard(type: .black, size: Size.heading)
        static let tabbar: UIFont = .pretendard(type: .semiBold, size: Size.tabbar)
    }
    
    enum Heading {
        static let bold: UIFont = .pretendard(type: .bold, size: Size.heading)
    }
    
    enum Title {
        static let black: UIFont = .pretendard(type: .black, size: Size.title)
        static let bold: UIFont = .pretendard(type: .bold, size: Size.title)
    }
    
    enum Title2 {
        static let bold: UIFont = .pretendard(type: .bold, size: Size.title2)
        static let semiBold: UIFont = .pretendard(type: .semiBold, size: Size.title2)
    }
    
    enum Title3 {
        static let bold: UIFont = .pretendard(type: .bold, size: Size.title3)
        static let semiBold: UIFont = .pretendard(type: .semiBold, size: Size.title3)
        static let medium: UIFont = .pretendard(type: .medium, size: Size.title3)
        static let regular: UIFont = .pretendard(type: .regular, size: Size.title3)
    }
    
    enum Body1 {
        static let bold: UIFont = .pretendard(type: .bold, size: Size.body1)
        static let semiBold: UIFont = .pretendard(type: .semiBold, size: Size.body1)
        static let medium: UIFont = .pretendard(type: .medium, size: Size.body1)
        static let regular: UIFont = .pretendard(type: .regular, size: Size.body1)
    }
    
    enum Body2 {
        static let bold: UIFont = .pretendard(type: .bold, size: Size.body2)
        static let semiBold: UIFont = .pretendard(type: .semiBold, size: Size.body2)
        static let medium: UIFont = .pretendard(type: .medium, size: Size.body2)
        static let regular: UIFont = .pretendard(type: .regular, size: Size.body2)
    }
}
