//
//  MemberInfo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import Foundation

// MARK: - Member
enum MemberPositionType {
    case owner
    case host
    case member
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

