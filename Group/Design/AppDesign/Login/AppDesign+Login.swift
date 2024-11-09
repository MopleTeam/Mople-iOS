//
//  AppDesign+Login.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import Foundation

extension AppDesign {
    enum Login: UIConstructive {
        // Text
        case title
        case subTitle
        
        var itemConfig: ItemConfigure {
            switch self {
            case .title:
                return makeUIConfigure(text: "모임관리",
                                       font: FontStyle.Head.black,
                                       color: AppDesign.defaultBlue)
                
            case .subTitle:
                return makeUIConfigure(text: "모임부터 약속까지 간편한 관리",
                                       font: FontStyle.Title3.regular,
                                       color: AppDesign.defaultGray)
            }
        }
    }
}
