//
//  MemberInfo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit

// MARK: - Memebr
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

struct MemberInfo: Hashable {
    let memberId: Int?
    let nickname: String?
    let imagePath: String?
    var position: MemberPositionType = .member
}

extension MemberInfo {
    mutating func assignPosition(type: MemberListType) {

    }
}

