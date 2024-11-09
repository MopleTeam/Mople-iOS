//
//  AppDesign+Schedule.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import Foundation

extension AppDesign {
    enum Schedule: UIConstructive {
        
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
                                       color: .init(hexCode: "888888"))
            case .title:
                return makeUIConfigure(font: FontStyle.Title.bold,
                                       color: AppDesign.defaultBlack)
            case .smallTitle:
                return makeUIConfigure(font: FontStyle.Title2.bold,
                                       color: AppDesign.defaultBlack)
            case .count:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: AppDesign.defaultGray,
                                       image: .member)
            case .date:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: AppDesign.defaultGray,
                                       image: .date)
            case .place:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: AppDesign.defaultGray,
                                       image: .place)
            case .moreSchedule:
                return makeUIConfigure(text: "더보기",
                                       font: FontStyle.Title3.bold,
                                       color: .init(hexCode: "555555"),
                                       image: .plus)
            case .pop:
                return makeUIConfigure(font: FontStyle.Body2.bold,
                                       color: .init(hexCode: "668CFF"),
                                       image: .pop)
            }
        }
    }
}
