//
//  MemberInfo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import Foundation

// MARK: - Member
public enum MemberPositionType {
    case owner
    case host
    case member
}

public struct MemberInfo: Hashable {
    public let memberId: Int?
    public let nickname: String?
    public let imagePath: String?
    public var position: MemberPositionType = .member

    public init(memberId: Int? = nil, nickname: String? = nil, imagePath: String? = nil, position: MemberPositionType = .member) {
        self.memberId = memberId
        self.nickname = nickname
        self.imagePath = imagePath
        self.position = position
    }
}

public extension MemberInfo {
    public mutating func assignPosition(type: MemberListType) {

    }
}

