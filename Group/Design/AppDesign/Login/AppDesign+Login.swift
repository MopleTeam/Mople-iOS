//
//  AppDesign+Login.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    enum Login: UIConstructive {
        
        static let kakaoColor: UIColor = .init(hexCode: "#FEE500")
        static let appleColor: UIColor = .init(hexCode: "000000")
        
        // Text
        case title
        case subTitle
        case kakao
        case apple
        
        var itemConfig: ItemConfigure {
            switch self {
            case .title:
                makeUIConfigure(text: "모임관리",
                                       font: FontStyle.Head.black,
                                       color: AppDesign.defaultBlue)
                
            case .subTitle:
                makeUIConfigure(text: "모임부터 약속까지 간편한 관리",
                                       font: FontStyle.Title3.regular,
                                       color: AppDesign.defaultGray)
            case .kakao:
                makeUIConfigure(text: "카카오로 시작하기",
                                font: FontStyle.Title3.semiBold,
                                color: AppDesign.defaultBlack,
                                image: .kakao)
            case .apple:
                makeUIConfigure(text: "Apple로 시작하기",
                                font: FontStyle.Title3.semiBold,
                                color: AppDesign.defaultWihte,
                                image: .apple)
            }
        }
    }
}
