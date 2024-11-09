//
//  AppDesign+Setup.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Setup: UIConstructive {
        
        static let borderColor: UIColor = .init(hexCode: "F7F7F8")
        
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
                                       color: AppDesign.defaultBlack,
                                       image: .editPan)
            case .notify:
                return makeUIConfigure(text: "알림 관리",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "3E4145"),
                                       image: .listArrow)
            case .presonalInfo:
                return makeUIConfigure(text: "개인정보 처리방침",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "3E4145"),
                                       image: .listArrow)
            case .versionInfo:
                return makeUIConfigure(text: "버전정보",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "3E4145"))
            case .version:
                return makeUIConfigure(font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "CCCCCC"))
            case .logout:
                return makeUIConfigure(text: "로그아웃",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "3E4145"))
            case .resign:
                return makeUIConfigure(text: "회원탈퇴",
                                       font: FontStyle.Title3.medium,
                                       color: .init(hexCode: "3E4145"))
            }
        }
    }
}
