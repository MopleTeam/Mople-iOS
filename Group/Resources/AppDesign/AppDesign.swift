//
//  AppColor.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

typealias TextConfigure = (text: String, font: UIFont, color: UIColor)

protocol TextConstructive {
    var textConfig: TextConfigure { get }
}

struct AppDesign {
    
    static let defaultBlack = UIColor(hexCode: "222222")
    static let defaultWihte = UIColor(hexCode: "FFFFFF")
    static let defaultBlue = UIColor(hexCode: "3366FF")
    
    enum Login: TextConstructive {
        // Text
        case main
        case sub
        
        var textConfig: TextConfigure {
            switch self {
            case .main:
                return ("모임 관리",
                        .pretendard(type: .black, size: 24),
                        AppDesign.defaultBlue)
            case .sub:
                return ("모임부터 약속까지 간편한 관리",
                        .pretendard(type: .reqular, size: 16),
                        UIColor(hexCode: "666666"))
            }
        }
    }
    
    enum Profile: TextConstructive {
        
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
        case checkTitle
        case nextButton
        
        var textConfig: TextConfigure {
            switch self {
            case .main:
                return ("자신을 나타낼\n프로필을 설정해주세요",
                        .pretendard(type: .bold, size: 22),
                        AppDesign.defaultBlack)
            case .nameTitle:
                return ("닉네임",
                        .pretendard(type: .semiBold, size: 16),
                        AppDesign.defaultBlack)
            case .nameText:
                return ("프로 스케줄러",
                        .pretendard(type: .reqular, size: 14),
                        AppDesign.defaultBlack)
            case .checkButton:
                return ("중복확인",
                        .pretendard(type: .semiBold, size: 14),
                        AppDesign.defaultWihte)
            case .checkTitle:
                return ("이미 사용중인 닉네임입니다.",
                        .pretendard(type: .reqular, size: 14),
                        .clear)
            case .nextButton:
                return ("프로필 생성하기",
                        .pretendard(type: .semiBold, size: 16),
                        AppDesign.defaultWihte)
            }
        }
    }
}
