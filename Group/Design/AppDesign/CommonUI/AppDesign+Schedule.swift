//
//  AppDesign+Schedule.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import Foundation

extension AppDesign {
    enum Schedule: UIConstructive {
        
        static let bgColor = ColorStyle.Default.white
        
        case group
        case title
        case smallTitle
        case count
        case date
        case place
        case moreSchedule
        case pop
        
        var itemConfig: ItemConfigure {
            switch self {
            case .group:
                return makeUIConfigure(font: FontStyle.Body2.semiBold,
                                       color: ColorStyle.Gray._04)
            case .title:
                return makeUIConfigure(font: FontStyle.Title.bold,
                                       color: ColorStyle.Gray._01)
            case .smallTitle:
                return makeUIConfigure(font: FontStyle.Title2.bold,
                                       color: ColorStyle.Gray._01)
            case .count:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: ColorStyle.Gray._04,
                                       image: .member)
            case .date:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: ColorStyle.Gray._04,
                                       image: .date)
            case .place:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: ColorStyle.Gray._04,
                                       image: .place)
            case .moreSchedule:
                return makeUIConfigure(text: "더보기",
                                       font: FontStyle.Title3.bold,
                                       color: ColorStyle.Gray._03,
                                       image: .plus)
            case .pop:
                return makeUIConfigure(font: FontStyle.Body2.bold,
                                       color: ColorStyle.Default.blue,
                                       image: .pop)
            }
        }
    }
}
