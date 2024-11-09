//
//  AppDesign+Home.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Home: UIConstructive {
        static let notifyImage = UIImage(named: "bell")
        
        case title
        case makeGroup
        case makeSchedule
        
        var itemConfig: ItemConfigure {
            switch self {
            case .title:
                return makeUIConfigure(text: "모임관리",
                                       font: FontStyle.Title.black,
                                       color: AppDesign.defaultBlue)
                
            case .makeGroup:
                return makeUIConfigure(text: "새로운\n모임 만들기",
                                       font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultBlack,
                                       image: .init(named:"group"))
                
            case .makeSchedule:
                return makeUIConfigure(text: "새로운\n일정 만들기",
                                       font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultBlack,
                                       image: .init(named:"schedule"))
            }
        }
    }
}
