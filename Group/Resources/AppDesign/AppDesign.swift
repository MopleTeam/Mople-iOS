//
//  AppColor.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

typealias ItemConfigure = (text: String?,
                           font: UIFont?,
                           color: UIColor?,
                           image: UIImage?)

protocol UIConstructive {
    var itemConfig: ItemConfigure { get }
}

extension UIConstructive {
    func makeUIConfigure(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil,
                         image: UIImage? = nil) -> ItemConfigure {
        return (text, font, color, image)
    }
}

struct AppDesign {
    
    static let mainBackColor = UIColor(hexCode: "F5F5F5")
    static let defaultBlack = UIColor(hexCode: "222222")
    static let defaultWihte = UIColor(hexCode: "FFFFFF")
    static let defaultBlue = UIColor(hexCode: "3366FF")
    static let defaultGray = UIColor(hexCode: "666666")
    static let defaultGray2 = UIColor(hexCode: "888888")
    
}

// MARK: - App Design
extension AppDesign {
    
    enum Main: UIConstructive {
        case NaviView
        
        var itemConfig: ItemConfigure {
            switch self {
            case .NaviView:
                return makeUIConfigure(font: .pretendard(type: .bold, size: 18))
            }
        }
    }
}

// MARK: - Login Flow Design
extension AppDesign {
    enum Login: UIConstructive {
        // Text
        case title
        case subTitle
        
        var itemConfig: ItemConfigure {
            switch self {
            case .title:
                return makeUIConfigure(text: "모임관리",
                                       font: .pretendard(type: .black, size: 24),
                                       color: AppDesign.defaultBlue)
                
            case .subTitle:
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
        
        var itemConfig: ItemConfigure {
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
}

// MARK: - Home Flow Design
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
                                       font: .pretendard(type: .black, size: 20),
                                       color: AppDesign.defaultBlue)
                
            case .makeGroup:
                return makeUIConfigure(text: "새로운\n모임 만들기",
                                       font: .pretendard(type: .semiBold, size: 16),
                                       color: AppDesign.defaultBlack,
                                       image: .init(named:"group"))
                
            case .makeSchedule:
                return makeUIConfigure(text: "새로운\n일정 만들기",
                                       font: .pretendard(type: .semiBold, size: 16),
                                       color: AppDesign.defaultBlack,
                                       image: .init(named:"schedule"))
            }
        }
    }
    
    enum HomeSchedule: UIConstructive {
        
        static let remainingDateLabel = AppDesign.defaultBlue.withAlphaComponent(0.1)
        static let participantCountLabel = AppDesign.defaultGray2.withAlphaComponent(0.1)
        
        case day
        case title
        case placeInfo
        case detailPlaceInfo
        case dateInfo
        case count
        case moreSchedule
        
        var itemConfig: ItemConfigure {
            switch self {
            case .day:
                return makeUIConfigure(font: .pretendard(type: .bold, size: 12),
                                       color: defaultBlue)
            case .title:
                return makeUIConfigure(font: .pretendard(type: .bold, size: 20),
                                       color: AppDesign.defaultBlack)
            case .placeInfo:
                return makeUIConfigure(font: .pretendard(type: .medium, size: 14),
                                       color: AppDesign.defaultGray,
                                       image: .init(named: "place"))
                
            case .detailPlaceInfo:
                return makeUIConfigure(font: .pretendard(type: .medium, size: 14),
                                       color: AppDesign.defaultGray,
                                       image: .init(named: "place"))
                
            case .dateInfo:
                return makeUIConfigure(font: .pretendard(type: .medium, size: 14),
                                       color: AppDesign.defaultGray,
                                       image: .init(named: "date"))
                
                
            case .count:
                return makeUIConfigure(font: .pretendard(type: .semiBold, size: 12),
                                       color: AppDesign.defaultGray2)
            case .moreSchedule:
                return makeUIConfigure(text: "더보기",
                                       font: .pretendard(type: .semiBold, size: 20),
                                       color: AppDesign.defaultGray)
            }
        }
    }
}

// MARK: - GroupList Flow Design
extension AppDesign {
    
    enum Group: UIConstructive {
        static let scheduleBack = UIColor(hexCode: "F6F7FA")
        
        case title
        case empty
        case member
        case schedule
        case arrow
        
        var itemConfig: ItemConfigure {
            switch self {
                
            case .title:
                return makeUIConfigure(font: .pretendard(type: .semiBold, size: 16),
                                       color: AppDesign.defaultBlack)
            case .empty:
                return makeUIConfigure(text: "새로운 모임을 추가해주세요",
                                       font: .pretendard(type: .medium, size: 16),
                                       color: .init(hexCode: "CCCCCC"),
                                       image: .init(named: "emptyGroup"))
            case .member:
                return makeUIConfigure(font: .pretendard(type: .medium, size: 12),
                                       color: AppDesign.defaultGray2,
                                       image: .init(named: "member"))
           
            case .schedule:
                return makeUIConfigure(font: .pretendard(type: .medium, size: 14),
                                       color: AppDesign.defaultGray2)
            case .arrow:
                return makeUIConfigure(image: .init(named: "listArrow"))
            }
        }
    }
}


