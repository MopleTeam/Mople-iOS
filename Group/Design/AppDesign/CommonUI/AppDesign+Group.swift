//
//  AppDesign+Group.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Group: UIConstructive {
        static let scheduleBack = UIColor.init(hexCode: "F6F7FA")
        
        case title
        case empty
        case member
        case schedule
        case arrow
        
        var itemConfig: ItemConfigure {
            switch self {
                
            case .title:
                return makeUIConfigure(font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultBlack)
            case .empty:
                return makeUIConfigure(text: "새로운 모임을 추가해주세요",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "CCCCCC"),
                                       image: .init(named: "emptyGroup"))
            case .member:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: .init(hexCode: "888888"),
                                       image: .init(named: "member"))
           
            case .schedule:
                return makeUIConfigure(font: FontStyle.Body1.medium,
                                       color: .init(hexCode: "888888"))
            case .arrow:
                return makeUIConfigure(image: .init(named: "listArrow"))
            }
        }
    }
}
