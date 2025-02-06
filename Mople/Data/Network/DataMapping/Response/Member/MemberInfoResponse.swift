//
//  MemberInfoResponse.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import Foundation

struct MemberInfoResponse: Decodable {
    let memberId: Int?
    let nickname: String?
    let image: String?
}

extension MemberInfoResponse {
    func toDomain() -> MemberInfo {
        return .init(memberId: memberId,
                     nickname: nickname,
                     imagePath: image)
    }
}
