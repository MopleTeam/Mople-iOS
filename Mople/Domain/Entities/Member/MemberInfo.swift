//
//  MemberInfo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit

enum MemberPositionType {
    case owner
    case host
    case member
    
    var image: UIImage? {
        switch self {
        case .owner:
            return .owner
        case .host:
            return .host
        case .member:
            return nil
        }
    }
}

struct MemberInfo: Equatable {
    let memberId: Int?
    let nickname: String?
    let imagePath: String?
    var position: MemberPositionType?
    
    static func < (lhs: MemberInfo, rhs: MemberInfo) -> Bool {
        guard let lhsName = lhs.nickname,
              let rhsName = rhs.nickname else {
            return false
        }
        
        let lhsType = getNameSortPriority(lhsName)
        let rhsType = getNameSortPriority(rhsName)

        if lhsType == rhsType {
            return lhsName < rhsName
        } else {
            return lhsType < rhsType
        }
    }
    
    static func getNameSortPriority(_ str: String) -> Int {
        guard let firstChar = str.first else { return 0 }
        
        switch firstChar {
        case _ where ("\u{AC00}"..."힣").contains(firstChar):
            return 1
        case _ where firstChar.isLetter:
            return 2
        case _ where firstChar.isNumber:
            return 3
        default:
            return 4
        }
    }
}
