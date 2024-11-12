//
//  AppDesign+Setup.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Setup: UIConstructive {
        
        static let bgColor = ColorStyle.Default.white
        static let borderColor = ColorStyle.Border.primary
        
        case edit
        case notify
        case presonalInfo
        case versionInfo
        case version
        case logout
        case resign
        
        var itemConfig: ItemConfigure {
            switch self {
            case .edit:
                return makeUIConfigure(font: FontStyle.Title3.semiBold,
                                       color: ColorStyle.Gray._01,
                                       image: .editPan)
            case .notify:
                return makeUIConfigure(text: TextStyle.Setup.notifyTitle,
                                       font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._01,
                                       image: .listArrow)
            case .presonalInfo:
                return makeUIConfigure(text: TextStyle.Setup.policyTitle,
                                       font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._01,
                                       image: .listArrow)
            case .versionInfo:
                return makeUIConfigure(text: TextStyle.Setup.versionTitle,
                                       font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._01)
            case .version:
                return makeUIConfigure(font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._06)
            case .logout:
                return makeUIConfigure(text: TextStyle.Setup.logoutTitle,
                                       font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._01)
            case .resign:
                return makeUIConfigure(text: TextStyle.Setup.resignTitle,
                                       font: FontStyle.Title3.medium,
                                       color: ColorStyle.Gray._01)
            }
        }
    }
}
