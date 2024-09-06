//
//  AppColor.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

typealias UIConfigure = (text: String?, font: UIFont?, color: UIColor?, image: UIImage?)

protocol UIConstructive {
    var uiConfig: UIConfigure { get }
}

extension UIConstructive {
    func makeUIConfigure(text: String? = nil,
                                 font: UIFont? = nil,
                                 color: UIColor? = nil,
                                 image: UIImage? = nil) -> UIConfigure {
        return (text, font, color, image)
    }
}

struct AppDesign {
    
    static let defaultBlack = UIColor(hexCode: "222222")
    static let defaultWihte = UIColor(hexCode: "FFFFFF")
    static let defaultBlue = UIColor(hexCode: "3366FF")
    static let defaultGray = UIColor(hexCode: "666666")
    
    enum Login: UIConstructive {
        // Text
        case main
        case sub
        
        var uiConfig: UIConfigure {
            switch self {
            case .main:
                return makeUIConfigure(text: "모임관리",
                                font: .pretendard(type: .black, size: 24),
                                color: AppDesign.defaultBlue)
                
            case .sub:
                return makeUIConfigure(text: "모임부터 약속까지 간편한 관리",
                                       font: .pretendard(type: .reqular, size: 16),
                                       color: AppDesign.defaultGray)
            }
        }
    }
    
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
        case checkTitle
        case nextButton
        
        var uiConfig: UIConfigure {
            switch self {
            case .main:
                return makeUIConfigure(text: "자신을 나타낼\n프로필을 설정해주세요",
                                       font: .pretendard(type: .bold, size: 22),
                                       color: AppDesign.defaultBlack)
            case .nameTitle:
                return makeUIConfigure(text: "닉네임",
                                       font: .pretendard(type: .semiBold, size: 16),
                                       color: AppDesign.defaultBlack)
            case .nameText:
                
                return makeUIConfigure(text: "프로 스케줄러",
                                       font: .pretendard(type: .reqular, size: 14),
                                       color: AppDesign.defaultBlack)
            case .checkButton:
                return makeUIConfigure(text: "중복확인",
                                       font: .pretendard(type: .semiBold, size: 14),
                                       color: AppDesign.defaultWihte)
            case .checkTitle:
                return makeUIConfigure(text: "이미 사용중인 닉네임입니다.",
                                       font: .pretendard(type: .reqular, size: 14),
                                       color: .clear)
            case .nextButton:
                
                return makeUIConfigure(text: "프로필 생성하기",
                                       font: .pretendard(type: .semiBold, size: 16),
                                       color: AppDesign.defaultWihte)
            }
        }
    }
    
    enum Home: UIConstructive {
        static let BackColor = UIColor(hexCode: "F5F5F5")
        
        case title
        case notify
        case makeGroup
        case makeSchedule
        
        var uiConfig: UIConfigure {
            switch self {
            case .title:
                return makeUIConfigure(text: "모임관리",
                                       font: .pretendard(type: .black, size: 20),
                                       color: AppDesign.defaultBlue)
            case .notify:
                return makeUIConfigure(image: UIImage(named: "Bell"))
                
            case .makeGroup:
                return makeUIConfigure(text: "모임 만들기",
                                       font: .pretendard(type: .bold, size: 16),
                                       color: AppDesign.defaultBlack,
                                       image: UIImage(named:"makeGroup"))
                
            case .makeSchedule:
                return makeUIConfigure(text: "모임 만들기",
                                       font: .pretendard(type: .bold, size: 16),
                                       color: AppDesign.defaultBlack,
                                       image: UIImage(named:"makeSchedule"))
            }
        }
    }
    
    enum HomeSchedule: UIConstructive {
        
        static let remainingDateLabel = AppDesign.defaultBlue.withAlphaComponent(0.1)
        static let participantCountLabel = UIColor(hexCode: "888888").withAlphaComponent(0.1)
        
        case day
        case title
        case info
        case count
        
        var uiConfig: UIConfigure {
            switch self {
            case .day:
                return makeUIConfigure(text: "스케쥴까지 남은 일 수",
                                       font: .pretendard(type: .bold, size: 12),
                                       color: defaultBlue)
            case .title:
                return makeUIConfigure(text: "스케쥴 제목",
                                       font: .pretendard(type: .medium, size: 20),
                                       color: AppDesign.defaultBlack)
            case .info:
                return makeUIConfigure(text: "스케쥴 상세정보",
                                       font: .pretendard(type: .bold, size: 14),
                                       color: AppDesign.defaultGray)
            case .count:
                return makeUIConfigure(text: "명수",
                                       font: .pretendard(type: .semiBold, size: 12),
                                       color: UIColor(hexCode: "888888"))
            }
        }
    }
}


