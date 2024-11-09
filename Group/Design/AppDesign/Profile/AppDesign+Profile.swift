//
//  AppDesign+Profile.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Profile: UIConstructive {
        
        // Image
        static let selectImage = UIImage(named: "selectImage")
        static let defaultImage = UIImage(named: "defaultImage")
        
        // Back Color
        static let textFieldBackColor = UIColor(hexCode: "F6F8FA")
        static let checkButtonBackColor = UIColor(hexCode: "3E3F40")
        static let nextButtonBackColor = AppDesign.defaultBlue

        // Text
        case main
        case nameTitle
        case nameText
        case checkButton
        case checkLabel
        case overlapTitle
        case nonOverlapTitle
        case nextButton
        
        var itemConfig: ItemConfigure {
            switch self {
            case .main:
                return makeUIConfigure(text: "자신을 나타낼\n프로필을 설정해주세요",
                                       font: FontStyle.Heading.bold,
                                       color: AppDesign.defaultBlack)
            case .nameTitle:
                return makeUIConfigure(text: "닉네임",
                                       font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultBlack)
            case .nameText:
                
                return makeUIConfigure(text: "프로 스케줄러",
                                       font: FontStyle.Body1.regular,
                                       color: AppDesign.defaultBlack)
            case .checkButton:
                return makeUIConfigure(text: "중복확인",
                                       font: FontStyle.Body1.semiBold,
                                       color: AppDesign.defaultWihte)
                
            case .checkLabel:
                return makeUIConfigure(font: FontStyle.Body1.regular)
                
                
            case .overlapTitle:
                return makeUIConfigure(text: "이미 사용중인 닉네임 입니다.",
                                       color: .init(hexCode: "FF3B30"))
                
            case .nonOverlapTitle:
                return makeUIConfigure(text: "사용 가능한 닉네임 입니다.",
                                       color: AppDesign.defaultBlack)
                
            case .nextButton:
                
                return makeUIConfigure(font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultWihte)
            }
        }
    }
}
