//
//  FontStyle.swift
//  Group
//
//  Created by CatSlave on 11/9/24.

import UIKit

enum FontStyle {
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
        static let title = FontFamily.Pretendard.black.font(size: Size.heading)
        static let tabbar = FontFamily.Pretendard.semiBold.font(size: Size.tabbar)
    }

    enum Heading {
        static let bold = FontFamily.Pretendard.bold.font(size: Size.heading)
    }

    enum Title {
        static let black = FontFamily.Pretendard.black.font(size: Size.title)
        static let bold = FontFamily.Pretendard.bold.font(size: Size.title)
    }

    enum Title2 {
        static let bold = FontFamily.Pretendard.bold.font(size: Size.title2)
        static let semiBold = FontFamily.Pretendard.semiBold.font(size: Size.title2)
    }

    enum Title3 {
        static let bold = FontFamily.Pretendard.bold.font(size: Size.title3)
        static let semiBold = FontFamily.Pretendard.semiBold.font(size: Size.title3)
        static let medium = FontFamily.Pretendard.medium.font(size: Size.title3)
        static let regular = FontFamily.Pretendard.regular.font(size: Size.title3)
    }

    enum Body1 {
        static let bold = FontFamily.Pretendard.bold.font(size: Size.body1)
        static let semiBold = FontFamily.Pretendard.semiBold.font(size: Size.body1)
        static let medium = FontFamily.Pretendard.medium.font(size: Size.body1)
        static let regular = FontFamily.Pretendard.regular.font(size: Size.body1)
    }

    enum Body2 {
        static let bold = FontFamily.Pretendard.bold.font(size: Size.body2)
        static let semiBold = FontFamily.Pretendard.semiBold.font(size: Size.body2)
        static let medium = FontFamily.Pretendard.medium.font(size: Size.body2)
        static let regular = FontFamily.Pretendard.regular.font(size: Size.body2)
    }
}
