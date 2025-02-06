//
//  MemberList.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import Foundation

struct MemberListResponse: Decodable {
    let creatorId: Int?
    let members: [MemberInfoResponse]
}

extension MemberListResponse {
    func toDomain() -> MemberList {
        return .init(creatorId: creatorId,
                     membsers: members.map({ $0.toDomain() }))
    }
}

